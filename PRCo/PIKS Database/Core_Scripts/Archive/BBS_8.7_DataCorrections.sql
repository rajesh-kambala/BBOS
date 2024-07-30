--8.7 Release
USE CRM

--Defect 6801
--L100 purchasable, and pricing overrides
UPDATE NewProduct SET prod_PurchaseInBBOS='Y' WHERE Prod_ProductID=85 and prod_Code='L100' --previously was NULL

--Defect 6800
UPDATE PRBBOSPrivilege SET AccessLevel=300 WHERE IndustryType='L' AND Privilege = 'ViewCompanyListing'

--Populate new PRCommodityCategory table
TRUNCATE TABLE PRCommodityCategory --make sure it's empty to start
DECLARE @NextID int

-----------------------------------------------------
-- Flower/Plant/Tree (1)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 1, 1, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Edible Flower (2)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 1, 2, -1, GETDATE(), -1, GETDATE(), GETDATE())

-----------------------------------------------------
-- Aloe Vera (4)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 1, 4, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bedding Plant (5)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 1, 5, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Christmas Greens (7)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 1, 7, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Christmas Trees (8)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 1, 8, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Nopales (10)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 10, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 10, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 109, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 37, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sorghum (12)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 12, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 16, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sugar Cane (13)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 13, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Flower (14)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 1, 14, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Plant (15)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 1, 15, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Food (non-produce) (16)
-----------------------------------------------------
--DUPLICATE -- EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
--DUPLICATE -- INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
--DUPLICATE -- 	VALUES(@NextID, 16, 16, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Candy (17)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 17, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cheese (18)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 18, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chocolate (19)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 19, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cocoa (20)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 20, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Coffee (21)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 21, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cole Slaw (22)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 22, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mix Cole Slaw (23)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 22, 23, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 23, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Couscous (24)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 24, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Egg (25)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 25, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Guacamole (26)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 26, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Honey (27)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 27, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Jelly (28)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 28, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pasta (29)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 29, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Potato Salad (30)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 30, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Preserves (31)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 31, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Relish (32)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 32, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rice (33)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 33, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sesame Seeds (34)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 34, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sunflower Seed (35)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 35, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tofu (36)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 36, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fruit (37)
-----------------------------------------------------
 
-----------------------------------------------------
-- Asian Fruit (38)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 38, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Durian (40)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 38, 40, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 40, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Longan (42)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 38, 42, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 42, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Loquat (43)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 38, 43, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 43, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Lychee (44)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 38, 44, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 44, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Persimmon (45)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 38, 45, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 45, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Quince (46)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 38, 46, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 46, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Berries (47)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 47, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Boysenberry Berry (49)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 47, 49, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 49, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Gooseberry Berry (50)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 47, 50, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 50, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Blackberry (51)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 47, 51, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 51, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Marion Blackberry (52)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 51, 52, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 47, 52, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 52, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Blueberry (53)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 47, 53, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 53, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cranberry (54)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 47, 54, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 54, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Currant (55)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 47, 55, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 55, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Red Currant (56)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 55, 56, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 47, 56, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 56, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Raspberry (57)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 47, 57, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 57, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Citrus (59)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 59, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Buddha Hand (60)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 60, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 60, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Etrog (61)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 61, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 61, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Grapefruit (62)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 62, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 62, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Kumquat (63)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 63, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 63, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Lemon (64)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 64, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 64, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Lime (65)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 65, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 65, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Key Lime (66)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 65, 66, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 66, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 66, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mexican Key Lime (67)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 66, 67, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 65, 67, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 67, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 67, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Persian Lime (68)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 65, 68, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 68, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 68, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sweet Lime (69)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 65, 69, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 69, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 69, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mandarin (70)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 70, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 70, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Orange (71)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 71, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 71, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Valencia Orange (72)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 71, 72, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 72, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 72, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Temple Orange (73)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 71, 73, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 73, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 73, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sour Orange Orange (74)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 71, 74, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 74, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 74, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Navel Orange (75)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 71, 75, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 75, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 75, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Blood Orange (76)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 71, 76, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 76, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 76, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Minneola Orange (77)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 71, 77, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 77, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 77, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Juice Orange (78)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 71, 78, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 78, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 78, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pummelo (80)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 80, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 80, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tangelo (81)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 81, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 81, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tangerine (82)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 82, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 82, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Soft Fruit (83)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 83, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Strawberry (84)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 83, 84, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 84, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Specialty Fruit (85)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 85, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Carambola (86)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 85, 86, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 86, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cherimoya (87)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 85, 87, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 87, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Dragon Fruit (88)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 85, 88, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 88, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Jack Fruit (89)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 85, 89, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 89, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Stone Fruit (90)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 90, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Apricot (91)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 91, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 91, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Interspecific Apricot (92)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 91, 92, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 92, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 92, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Avocado (93)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 93, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 93, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cherry (94)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 94, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 94, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mango (98)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 98, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 98, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Nectarine (99)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 99, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 99, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- White Nectarine (100)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 99, 100, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 100, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 100, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Olive (101)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 101, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 101, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Peach (102)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 102, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 102, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- White Peach (103)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 102, 103, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 103, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 103, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Plum (104)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 104, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 104, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pluot (105)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 105, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 105, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Prune (106)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 106, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 106, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Italian Prune (107)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 106, 107, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 107, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 107, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rambutan (108)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 108, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 108, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tree Fruit (109)
-----------------------------------------------------
--DUPLICATE -- EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
--DUPLICATE -- INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
--DUPLICATE -- 	VALUES(@NextID, 37, 109, -1, GETDATE(), -1, GETDATE(), GETDATE())
--DUPLICATE -- EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
--DUPLICATE -- INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
--DUPLICATE -- 	VALUES(@NextID, 37, 37, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Apple (110)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 110, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 110, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Crab Apple (111)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 110, 111, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 111, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 111, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fuji Apple (112)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 110, 112, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 112, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 112, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Banana (116)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 116, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 116, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Leaf Banana (117)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 117, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 117, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 117, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Plantain Banana (118)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 118, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 118, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 118, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Hawaiian Plantain Banana (119)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 118, 119, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 119, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 119, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 119, -1, GETDATE(), -1, GETDATE(), GETDATE())

 
-----------------------------------------------------
-- Red Banana (121)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 121, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 121, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 121, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Manzano Banana (122)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 122, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 122, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 122, -1, GETDATE(), -1, GETDATE(), GETDATE())

 
-----------------------------------------------------
-- Burro Banana (123)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 123, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 123, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 123, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Breadfruit (124)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 124, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 124, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Date (128)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 128, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 128, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Medjool Date (129)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 128, 129, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 129, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 129, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pear (161)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 161, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 161, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Prickly Pear Cactus Pear (164)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 161, 164, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 164, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 164, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Asian Pear (165)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 161, 165, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 165, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 165, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Nashi Asian Pear (166)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 165, 166, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 161, 166, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 166, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 166, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tropical Fruit (182)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 182, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Atemoya (183)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 183, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 183, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chico Sapote (195)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 195, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 195, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Coconut (196)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 196, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 196, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Water Coconut (197)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 196, 197, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 197, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 197, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Dominicos (198)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 198, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 198, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Feijoa (199)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 199, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 199, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fig (200)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 200, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 200, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Guava (201)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 201, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 201, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Jujube (202)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 202, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 202, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Kiwifruit (203)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 203, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 203, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mamey (205)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 205, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 205, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mangosteen (207)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 207, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 207, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Papaya (208)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 208, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 208, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Green Papaya (209)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 208, 209, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 209, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 209, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Hawaiian Air Papaya (210)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 208, 210, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 210, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 210, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Passionfruit (211)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 211, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 211, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pineapple (213)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 213, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 213, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pitahaya (214)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 214, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 214, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pomegranate (215)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 215, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 215, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sapodillo (217)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 217, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 217, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sapote (218)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 218, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 218, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tamarillo (219)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 219, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 219, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tamarind (220)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 220, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 220, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Vine Fruit (221)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 221, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cantaloupe (222)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 222, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 222, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Grape (223)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 223, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 223, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Wine Grape (224)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 223, 224, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 224, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 224, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Honeydew (226)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 226, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 226, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Juice Grape (227)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 227, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 227, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Kiwano (228)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 228, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 228, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Melon (229)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 229, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 229, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Persian Melon (230)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 229, 230, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 230, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 230, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bittermelon Melon (231)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 229, 231, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 231, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 231, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Winter Melon (232)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 229, 232, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 232, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 232, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Horned Melon (233)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 229, 233, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 233, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 233, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Casaba Melon (235)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 229, 235, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 235, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 235, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Crenshaw Melon (236)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 229, 236, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 236, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 236, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Galia Melon (237)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 229, 237, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 237, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 237, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Raisin (241)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 241, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 241, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Watermelon (243)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 243, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 243, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Seedless Watermelon (244)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 243, 244, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 244, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 244, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Gift Basket (246)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 246, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Hispanic Fruit (247)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 247, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Herb (248)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 248, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Basil (249)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 249, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bay Leaf (250)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 250, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chervil (251)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 251, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chive (252)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 252, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cilantro (253)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 253, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Culantro (254)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 254, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Diep Ca (255)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 255, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Dill (256)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 256, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Epazote (257)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 257, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fennel (258)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 258, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Lemon Grass (259)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 259, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Marjoram (260)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 260, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mint (261)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 261, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Peppermint Mint (262)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 261, 262, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 262, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Oregano (263)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 263, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Parsley (264)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 264, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rau Ram (265)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 265, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rosemary (266)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 266, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sage (267)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 267, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Savory (268)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 268, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tarragon (269)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 269, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Thyme (270)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 270, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Nut (271)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 271, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Almond (272)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 272, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Brazil Nut (273)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 273, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cashew (274)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 274, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chestnut (275)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 275, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Italian Chestnut (276)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 275, 276, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 276, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Filbert (277)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 277, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Hazelnut (278)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 278, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Macadamia (279)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 279, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Peanut (280)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 280, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fresh Green Peanut (281)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 280, 281, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 281, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pecan (282)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 282, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pine Nut (283)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 283, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pistachio (284)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 284, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Walnut (285)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 271, 285, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Spice (287)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 287, 287, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Anise (288)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 287, 288, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fenugreek Seeds (289)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 287, 289, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Vegetable (291)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 291, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Asian Vegetable (292)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 292, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bac Ha (293)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 292, 293, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 293, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bamboo Shoot (294)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 292, 294, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 294, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bok Choy (295)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 292, 295, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 295, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Daikon (296)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 292, 296, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 296, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Gai Choy (297)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 292, 297, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 297, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rau Day (298)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 292, 298, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 298, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tindora (299)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 292, 299, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 299, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yu Choy Sum (300)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 292, 300, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 300, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bulb (301)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 301, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Garlic (302)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 302, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 302, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Braid Garlic (303)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 302, 303, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 303, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 303, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Elephant Garlic (304)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 302, 304, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 304, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 304, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Green Onion (305)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 305, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 305, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Scallion Green Onion (306)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 305, 306, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 306, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 306, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Kohlrabi (307)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 307, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 307, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Leek (308)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 308, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 308, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Onion (309)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 309, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 309, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yellow Onion (310)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 309, 310, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 310, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 310, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sweet Onion (311)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 309, 311, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 311, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 311, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- White Onion (312)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 309, 312, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 312, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 312, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Seed Onion (313)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 309, 313, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 313, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 313, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Red Onion (314)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 309, 314, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 314, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 314, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cipolline Onion (315)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 309, 315, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 315, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 315, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pearl Onion (316)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 309, 316, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 316, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 316, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Spanish Onion (317)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 309, 317, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 317, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 317, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Seed Garlic (318)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 318, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 318, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Shallot (319)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 319, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 319, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Butternut Squash (321)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 321, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 321, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 338, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chayote (322)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 322, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 322, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pumpkin (323)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 323, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 323, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Squash (324)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 324, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 324, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Zucchini Squash (326)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 326, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 326, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 326, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mexican Squash (327)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 327, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 327, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 327, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Hard shell Squash (328)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 328, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 328, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 328, -1, GETDATE(), -1, GETDATE(), GETDATE())

-----------------------------------------------------
-- Banana Hard shell Squash (329)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 328, 329, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 329, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 329, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 329, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Kabocha Hard shell Squash (330)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 328, 330, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 330, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 330, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 330, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Acorn Hard shell Squash (331)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 328, 331, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 331, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 331, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 331, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Spaghetti Hard shell Squash (332)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 328, 332, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 332, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 332, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 332, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Italian Squash (333)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 333, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 333, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 333, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Courgette Squash (334)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 334, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 334, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 334, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chinese Squash (335)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 335, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 335, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 335, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yellow Squash (336)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 336, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 336, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 336, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Gourd (338)
-----------------------------------------------------
--DUPLICATE -- EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
--DUPLICATE -- INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
--DUPLICATE -- 	VALUES(@NextID, 291, 338, -1, GETDATE(), -1, GETDATE(), GETDATE())
--DUPLICATE -- EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
--DUPLICATE -- INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
--DUPLICATE -- 	VALUES(@NextID, 291, 291, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Ornamental Gourd (339)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 339, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 339, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Hispanic Vegetable (340)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 340, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Jicama (341)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 340, 341, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 341, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Inflorescent (342)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 342, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Artichoke (343)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 342, 343, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 343, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Broccoflower (344)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 342, 344, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 344, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Broccoli (345)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 342, 345, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 345, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Crown Broccoli (346)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 345, 346, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 342, 346, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 346, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rabe Broccoli (347)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 345, 347, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 342, 347, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 347, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cauliflower (348)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 342, 348, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 348, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Leafy Vegetable (349)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 349, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Arugula (350)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 350, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 350, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cabbage (352)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 352, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 352, -1, GETDATE(), -1, GETDATE(), GETDATE())

 
-----------------------------------------------------
-- Asian Cabbage (353)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 352, 353, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 353, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 353, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chinese Asian Cabbage (354)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 353, 354, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 352, 354, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 354, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 354, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Savoy Cabbage (355)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 352, 355, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 355, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 355, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Green Cabbage (356)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 352, 356, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 356, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 356, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Red Cabbage (357)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 352, 357, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 357, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 357, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Calaloo (358)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 358, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 358, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chard (359)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 359, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 359, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chicory (360)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 360, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 360, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Endigia Lettuce (361)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 361, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 361, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Endive (362)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 362, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 362, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Belgian Endive (363)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 362, 363, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 363, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 363, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Escarole (365)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 365, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 365, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fiddlehead Fern (366)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 366, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 366, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Frisee (368)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 368, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 368, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Greens (370)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 370, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 370, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Horseradish Greens (371)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 371, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 371, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 371, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rape Greens (372)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 372, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 372, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 372, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Kim Chee Greens (373)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 373, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 373, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 373, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mesclun (374)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 374, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 374, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 374, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Turnip Greens (375)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 375, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 375, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 375, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Horseradish (376)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 376, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 376, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 434, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Donqua Greens (377)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 377, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 377, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 377, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Dandelion Greens (378)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 378, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 378, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 378, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Collard Greens (379)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 379, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 379, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 379, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Beet Greens (380)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 380, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 380, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 380, -1, GETDATE(), -1, GETDATE(), GETDATE())

 
-----------------------------------------------------
-- Mustard Greens (381)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 381, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 381, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 381, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Micro Greens Greens (383)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 383, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 383, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 383, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Kale (384)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 384, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 384, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Lettuce (385)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 385, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 385, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bibb Lettuce (386)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 385, 386, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 386, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 386, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Boston Lettuce (387)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 385, 387, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 387, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 387, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Leaf Lettuce (388)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 385, 388, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 388, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 388, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mache Lettuce (389)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 385, 389, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 389, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 389, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Red Lettuce (390)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 385, 390, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 390, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 390, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Romaine Lettuce (391)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 385, 391, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 391, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 391, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Butter Lettuce (392)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 385, 392, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 392, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 392, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Radicchio (393)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 393, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 393, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rapini (394)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 394, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 394, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Salad (396)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 396, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 396, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sorrel (397)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 397, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 397, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Spinach (398)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 398, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 398, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Ong Choy Spinach (399)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 398, 399, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 399, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 399, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Spring Mix (400)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 400, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 400, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Watercress (401)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 401, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 401, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Legume (403)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 403, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bean (404)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 404, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 404, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Long Bean (405)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 405, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 405, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 405, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Wax Bean (406)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 406, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 406, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 406, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Black Bean (407)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 407, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 407, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 407, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sprout Bean (408)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 408, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 408, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 408, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Soybean Bean (409)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 409, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 409, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 409, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Snap Bean (410)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 410, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 410, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 410, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pole Bean Bean (411)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 411, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 411, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 411, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pinto Bean (412)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 412, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 412, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 412, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pea Bean (413)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 413, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 413, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 413, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Black-Eyed Pea Bean (414)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 413, 414, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 414, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 414, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 414, -1, GETDATE(), -1, GETDATE(), GETDATE())

 
-----------------------------------------------------
-- Chinese Long Bean (415)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 415, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 415, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 415, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Lentil Bean (416)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 416, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 416, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 416, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Kidney Bean (417)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 417, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 417, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 417, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Guar Bean (418)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 418, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 418, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 418, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Green Bean (419)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 419, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 419, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 419, -1, GETDATE(), -1, GETDATE(), GETDATE())

-----------------------------------------------------
-- Garbanzo Bean (420)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 420, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 420, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 420, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- French Bean (421)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 421, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 421, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 421, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Lima Bean (422)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 422, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 422, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 422, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fava Bean (423)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 423, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 423, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 423, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chili Dry Beans (424)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 424, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 424, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chinese Dry Beans (425)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 425, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 425, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Edamame (426)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 426, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 426, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pea (427)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 427, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 427, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Snow Pea (428)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 427, 428, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 428, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 428, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sugar Pea (429)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 427, 429, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 429, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 429, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Snap Sugar Pea (430)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 429, 430, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 427, 430, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 430, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 430, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chinese Pea (431)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 427, 431, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 431, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 431, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- English Pea (432)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 427, 432, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 432, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 432, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Snap Pea (433)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 427, 433, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 433, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 433, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Root Vegetable (434)
-----------------------------------------------------
--DUPLICATE -- EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
--DUPLICATE -- INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
--DUPLICATE -- 	VALUES(@NextID, 291, 434, -1, GETDATE(), -1, GETDATE(), GETDATE())
--DUPLICATE -- EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
--DUPLICATE -- INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
--DUPLICATE -- 	VALUES(@NextID, 291, 291, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Arrow Root (435)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 435, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 435, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Beet (436)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 436, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 436, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Boniato (437)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 437, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 437, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Carrot (438)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 438, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 438, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cassava (439)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 439, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 439, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Celery Root (440)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 440, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 440, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Ginger (442)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 442, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 442, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Root Ginger (443)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 442, 443, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 443, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 443, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Regular Root Ginger (444)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 443, 444, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 442, 444, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 444, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 444, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Thai Root Ginger (445)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 443, 445, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 442, 445, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 445, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 445, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Lotus Root (447)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 447, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 447, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Malanga (448)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 448, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 448, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Oyster Plant (449)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 449, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 449, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Parsnip (450)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 450, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 450, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Potato (451)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 451, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 451, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Processing Potato (452)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 451, 452, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 452, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 452, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chipper Potato (454)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 451, 454, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 454, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 454, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Radish (455)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 455, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 455, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Root (457)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 457, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 457, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Calabaza Root (458)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 457, 458, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 458, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 458, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Galanga Root (459)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 457, 459, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 459, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 459, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Gobo Root (460)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 457, 460, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 460, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 460, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Lily Root (461)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 457, 461, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 461, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 461, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rutabaga (462)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 462, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 462, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Seed Potatoes (463)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 463, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 463, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sunchokes (464)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 464, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 464, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sweet Potato (465)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 465, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 465, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Taro Root (466)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 466, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 466, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Turnip (467)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 467, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 467, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Waterchestnut (468)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 468, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 468, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yam (469)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 469, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 469, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yampi Yam (470)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 469, 470, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 470, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 470, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yellow Yam (471)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 469, 471, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 471, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 471, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yuca Root (472)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 472, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 472, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Stalk Vegetables (473)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 473, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Asparagus (474)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 473, 474, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 474, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Brussel Sprout (475)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 473, 475, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 475, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cardoon (476)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 473, 476, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 476, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Celery (477)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 473, 477, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 477, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cabbage Celery (478)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 477, 478, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 473, 478, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 478, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Heart Celery (479)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 477, 479, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 473, 479, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 479, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Rhubarb (480)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 473, 480, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 480, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tropical Vegetable (481)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 481, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Palm Heart (482)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 481, 482, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 482, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Corn (484)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 484, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Indian Corn (485)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 484, 485, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 485, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Ornamental Corn (486)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 484, 486, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 486, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sweet Corn (487)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 484, 487, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 487, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Popcorn Sweet Corn (488)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 487, 488, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 484, 488, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 488, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Husk Sweet Corn (489)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 487, 489, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 484, 489, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 489, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cucumber (491)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 491, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Seedless Cucumber (492)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 492, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 492, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Japanese Cucumber (494)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 494, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 494, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Persian Cucumber (495)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 495, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 495, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pickle Persian Cucumber (496)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 495, 496, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 496, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 496, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- European Cucumber (497)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 497, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 497, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- English Cucumber (498)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 498, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 498, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pickle Cucumber (499)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 499, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 499, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mexican Chili Pepper (500)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 500, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mushroom (501)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 501, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Shiitake Mushroom (502)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 501, 502, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 502, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Morel Mushroom (503)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 501, 503, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 503, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Okra (504)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 504, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pepper (505)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 505, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fresno Pepper (506)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 506, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 506, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Red Fresno Pepper (507)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 506, 507, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 507, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 507, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yellow Pepper (508)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 508, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 508, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Scotch Bonnet Pepper (509)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 509, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 509, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Serrano Pepper (510)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 510, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 510, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Red Pepper (511)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 511, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 511, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Poblano Pepper (512)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 512, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 512, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pasilla Pepper (513)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 513, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 513, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Jalapeno Pepper (514)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 514, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 514, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Hot Jalapeno Pepper (515)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 514, 515, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 515, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 515, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Habanero Pepper (516)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 516, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 516, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chili Pepper (517)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 517, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 517, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cayenne Red Pepper (518)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 518, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 518, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Anaheim Pepper (519)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 519, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 519, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Aji Cachucha Pepper (520)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 520, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 520, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bell Pepper (521)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 521, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 521, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yellow Bell Pepper (523)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 521, 523, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 523, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 523, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- White Bell Pepper (524)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 521, 524, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 524, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 524, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Red Bell Pepper (525)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 521, 525, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 525, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 525, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Purple Bell Pepper (526)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 521, 526, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 526, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 526, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Orange Bell Pepper (527)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 521, 527, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 527, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 527, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Thai Pepper (528)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 528, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 528, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cubanelle Pepper (529)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 529, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 529, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pimento (530)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 530, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sprout (531)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 531, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Alfalfa Sprout (532)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 531, 532, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 532, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Broccoli Sprout (533)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 531, 533, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 533, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Wheat Grass Sprout (534)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 531, 534, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 534, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tomato (535)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 535, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Roma Tomato (536)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 536, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 536, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Yellow Tomato (537)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 537, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 537, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Teardrop Tomato (538)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 538, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 538, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Plum Tomato (539)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 539, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 539, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Grape Tomato (540)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 540, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 540, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cherry Tomato (541)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 541, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 541, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tomatillo Tomato (543)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 543, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 543, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Eggplant (544)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 544, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Japanese Eggplant (545)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 544, 545, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 545, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Thai Eggplant (546)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 544, 546, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 546, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Italian Eggplant (547)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 544, 547, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 547, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Indian Eggplant (548)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 544, 548, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 548, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Chinese Eggplant (549)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 544, 549, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 549, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Specialty Vegetable (550)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 550, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Brown Fig (551)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 200, 551, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 551, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 551, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Turkey Brown Fig (552)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 551, 552, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 200, 552, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 552, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 552, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sierra Fig (553)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 200, 553, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 553, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 553, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Spearmint Mint (554)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 261, 554, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 554, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Root Asparagus (555)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 474, 555, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 473, 555, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 555, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Flower Banana (556)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 556, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 556, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 556, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Citrus Budwood (557)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 557, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 557, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Clementine Mandarin (558)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 70, 558, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 558, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 558, -1, GETDATE(), -1, GETDATE(), GETDATE())

 
-----------------------------------------------------
-- Deciduous Fruit (559)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 559, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mo Qua Squash (561)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 561, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 561, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 561, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Hairy Mo Qua Squash (562)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 561, 562, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 562, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 562, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 562, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Genip (563)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 563, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 563, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Greek Kiwifruit (564)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 203, 564, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 564, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 564, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Green Chili Pepper (565)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 517, 565, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 565, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 565, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Green Garlic (566)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 302, 566, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 566, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 566, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Green Mango (567)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 98, 567, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 567, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 567, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Guaje (568)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 568, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bitter gourd Melon (569)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 229, 569, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 221, 569, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 569, -1, GETDATE(), -1, GETDATE(), GETDATE())

-----------------------------------------------------
-- Manzano Chili Pepper (570)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 517, 570, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 570, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 570, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Matsutake Mushroom (571)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 501, 571, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 571, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Okinawa Sweet Potato (572)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 465, 572, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 572, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 572, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Ornamental Squash (573)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 324, 573, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 573, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 573, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Set Onion (574)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 309, 574, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 301, 574, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 574, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Ponkan Mandarin (575)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 70, 575, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 59, 575, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 575, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Poovan Banana (576)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 576, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 576, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 576, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Sherlihon Greens (577)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 370, 577, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 577, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 577, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Thai Basil (578)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 249, 578, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 578, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Tuber (579)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 579, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- On choy (580)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 580, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Caribe Pepper (581)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 581, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 581, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Alfalfa (582)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 582, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 582, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Plumcot (583)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 583, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 583, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Gai lan Kale (1500)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 384, 1500, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 1500, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1500, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Heirloom Tomato (1501)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 1501, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1501, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Banana Wax Pepper (1502)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 1502, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1502, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Beefsteak Tomato (1503)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 1503, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1503, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cluster Tomato (1504)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 535, 1504, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1504, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pomegranate Arils (1505)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 215, 1505, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 182, 1505, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 1505, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Fenugreek (1506)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 248, 1506, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pumpkin Seeds (1507)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 1507, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Cherry Plum (1508)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 104, 1508, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 1508, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 1508, -1, GETDATE(), -1, GETDATE(), GETDATE())

 
-----------------------------------------------------
-- Sour Cherry (1509)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 94, 1509, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 90, 1509, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 1509, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Turmeric (1510)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 434, 1510, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1510, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Finger Hot Chili Pepper (1511)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 517, 1511, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 505, 1511, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1511, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Bread Nut (1512)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 1512, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 1512, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Ash Plantain Banana (1513)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 118, 1513, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 1513, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 1513, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 1513, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Mocha Plantain Banana (1514)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 118, 1514, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 116, 1514, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 109, 1514, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 1514, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Dosakai Cucumber (1515)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 1515, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1515, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Parval Cucumber (1516)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 1516, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1516, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Snake Gourd Cucumber (1517)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 491, 1517, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1517, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Kantola (1518)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 338, 1518, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1518, -1, GETDATE(), -1, GETDATE(), GETDATE())
 
-----------------------------------------------------
-- Pigeon Pea (1519)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 427, 1519, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 1519, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1519, -1, GETDATE(), -1, GETDATE(), GETDATE())

 
-----------------------------------------------------
-- Valor Bean (1520)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 404, 1520, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 403, 1520, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1520, -1, GETDATE(), -1, GETDATE(), GETDATE())

-----------------------------------------------------
-- Bread Nut Seeds (1521)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 16, 1521, -1, GETDATE(), -1, GETDATE(), GETDATE())

-----------------------------------------------------
-- Napa Cabbage (1522)
-----------------------------------------------------
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 352, 1522, -1, GETDATE(), -1, GETDATE(), GETDATE())

EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 353, 1522, -1, GETDATE(), -1, GETDATE(), GETDATE())

EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 349, 1522, -1, GETDATE(), -1, GETDATE(), GETDATE())

EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1522, -1, GETDATE(), -1, GETDATE(), GETDATE())

GO

--Check results of loaded table
/*
	SELECT prcomcat_ParentId, prcomcat_CommodityId, prcm_FullName FROM PRCommodityCategory
		INNER JOIN PRCommodity ON prcm_CommodityId = prcomcat_CommodityID
	ORDER BY prcomcat_ParentID, prcomcat_CommodityID ASC
*/


-- Defect #4321  
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_Name, prpbar_FileName)
VALUES (200, 'MK', 'Blueprints Blue Book Online MediaKit', 'Blueprints_Blue Book Online MediaKit.pdf');
Go

INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
    VALUES (1522, 'Napa Cabbage', 'Napacab', 291, 353, 5,'Vegetable,Leafy Vegetable,Cabbage,Asian,Savoy,Napacab', 'V,LeafyVegetable,Cab,Asian', 'Bread Nut Seeds,Napa Cabbage', 'Napa Cabbage', 3125, 3, GETDATE(), 3, GETDATE(), GETDATE());
Go

--Defect 4644 -- Broccoli Rabe
UPDATE PRCommodity SET prcm_FullName = 'Broccoli Rabe' WHERE prcm_CommodityID=347

UPDATE PRCommodity 
   SET prcm_FullName = 'Sour orange' 
 WHERE prcm_CommodityID=74

UPDATE PRCommodity 
   SET prcm_FullName = 'Pole bean',
       prcm_FullName_ES = 'Menta verde' 
 WHERE prcm_CommodityID=411

UPDATE PRCommodity 
   SET prcm_FullName = 'Spearmint',
       prcm_FullName_ES = 'Menta verde' 
 WHERE prcm_CommodityID=554

 UPDATE PRCommodity 
   SET prcm_FullName = 'Peppermint',
       prcm_FullName_ES = 'Hierbabuena' 
 WHERE prcm_CommodityID=262

UPDATE PRCommodity 
   SET prcm_FullName = 'Prickly pear' 
 WHERE prcm_CommodityID=164

UPDATE PRCommodity 
   SET prcm_FullName = 'Juice grape' 
 WHERE prcm_CommodityID=227

UPDATE PRCommodity 
   SET prcm_FullName = 'Buddhas Hand' 
 WHERE prcm_CommodityID=60

UPDATE PRCommodity 
   SET prcm_FullName = 'Bittermelon' 
 WHERE prcm_CommodityID=231
Go

UPDATE PRCommodity SET prcm_Alias='Africian horned cucumber,Horned cucumber,Jelly melon' WHERE prcm_CommodityId=228
UPDATE PRCommodity SET prcm_Alias='Celery cabbage,Da bai cai,Wong Bok' WHERE prcm_CommodityId=354
UPDATE PRCommodity SET prcm_Alias=NULL WHERE prcm_CommodityId=360
UPDATE PRCommodity SET prcm_Alias='Coco,Dasheen,Eddo,Eddoes,Hung Nga Woo Tau,Malanga Islena,Sato Imo,Tannia,Tannier,Woo Tau' WHERE prcm_CommodityId=466
Go



EXEC usp_PopulatePRCommodity2
Go

UPDATE PRCommodity2 SET prcm_Abbreviation = REPLACE(prcm_Abbreviation COLLATE Latin1_General_BIN, 'Rabebc', 'Bcrabe')
	WHERE prcm_CommodityID=347
UPDATE PRCommodity2 SET prcm_Abbreviation = REPLACE(prcm_Abbreviation COLLATE Latin1_General_BIN, 'rabebc', 'bcrabe')
	WHERE prcm_CommodityID=347
UPDATE PRCommodity2 SET prcm_Description = REPLACE(prcm_Description COLLATE Latin1_General_BIN, 'Rabe broccoli', 'Broccoli rabe')
	WHERE prcm_CommodityID=347
UPDATE PRCommodity2 SET prcm_Description = REPLACE(prcm_Description COLLATE Latin1_General_BIN, 'rabe broccoli', 'broccoli rabe')
	WHERE prcm_CommodityID=347
Go

UPDATE PRCommodity2 
   SET prcm_Description = 'Pole bean'
 WHERE prcm_CommodityID=411  AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL

UPDATE PRCommodity2 
   SET prcm_Description = REPLACE(prcm_Description, 'pole bean bean', 'pole bean')
 WHERE prcm_CommodityID=411  
   AND (prcm_AttributeID IS NOT NULL OR prcm_GrowingMethodID IS NOT NULL)
  

UPDATE PRCommodity2 
   SET prcm_Description = 'Spearmint',
       prcm_Description_ES = 'Menta verde'
 WHERE prcm_CommodityID=554  AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL

UPDATE PRCommodity2 
   SET prcm_Description = REPLACE(prcm_Description, 'spearmint mint', 'spearmint'),
       prcm_Description_ES = REPLACE(prcm_Description_ES, 'menta verde menta', 'menta verde')
 WHERE prcm_CommodityID=554  
   AND (prcm_AttributeID IS NOT NULL OR prcm_GrowingMethodID IS NOT NULL)


UPDATE PRCommodity2 
   SET prcm_Description = 'Peppermint' ,
       prcm_Description_ES = 'Hierbabuena'
 WHERE prcm_CommodityID=262  AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL

UPDATE PRCommodity2 
   SET prcm_Description = REPLACE(prcm_Description, 'peppermint mint', 'peppermint'),
       prcm_Description_ES = REPLACE(prcm_Description_ES, 'hierbabuena menta', 'hierbabuena')
 WHERE prcm_CommodityID=262  
   AND (prcm_AttributeID IS NOT NULL OR prcm_GrowingMethodID IS NOT NULL)


UPDATE PRCommodity2 
   SET prcm_Description = 'Prickly pear' 
 WHERE prcm_CommodityID=164  AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL

UPDATE PRCommodity2 
   SET prcm_Description = REPLACE(prcm_Description, 'pear pear', 'pear')
 WHERE prcm_CommodityID=164  
   AND (prcm_AttributeID IS NOT NULL OR prcm_GrowingMethodID IS NOT NULL)


UPDATE PRCommodity2 
   SET prcm_Description = 'Juice grape' 
 WHERE prcm_CommodityID=227  AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL


UPDATE PRCommodity2 
   SET prcm_Description = 'Buddhas Hand' 
 WHERE prcm_CommodityID=60  AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL

UPDATE PRCommodity2 
   SET prcm_Description = REPLACE(prcm_Description, 'buddha hand', 'buddhas hand')
 WHERE prcm_CommodityID=60
   AND (prcm_AttributeID IS NOT NULL OR prcm_GrowingMethodID IS NOT NULL)



UPDATE PRCommodity2 
   SET prcm_Description = 'Bittermelon' 
 WHERE prcm_CommodityID=231 AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL

UPDATE PRCommodity2 
   SET prcm_Description = REPLACE(prcm_Description, 'bittermelon melon', 'bittermelon')
 WHERE prcm_CommodityID=231 
   AND (prcm_AttributeID IS NOT NULL OR prcm_GrowingMethodID IS NOT NULL)


UPDATE PRCommodity2 
   SET prcm_Description = 'Sour orange',
       prcm_Description_ES = 'Naranja agria' 
 WHERE prcm_CommodityID=74 AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL

UPDATE PRCommodity2 
   SET prcm_Description = REPLACE(prcm_Description, 'orange orange', 'orange'),
       prcm_Description_ES = REPLACE(prcm_Description_ES, 'naranja agria naranja', 'naranja agria')
 WHERE prcm_CommodityID=74 
   AND (prcm_AttributeID IS NOT NULL OR prcm_GrowingMethodID IS NOT NULL)


UPDATE PRCommodity2 
   SET prcm_Description = 'Sour cherry',
       prcm_Description_ES = 'Cereza agria'
 WHERE prcm_CommodityID=1509 AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL

UPDATE PRCommodity2 
   SET prcm_Description = REPLACE(prcm_Description, 'cherry cherry', 'cherry'),
       prcm_Description_ES = REPLACE(prcm_Description_ES, 'cereza agria cereza', 'cereza agria')
 WHERE prcm_CommodityID=1509 
   AND (prcm_AttributeID IS NOT NULL OR prcm_GrowingMethodID IS NOT NULL)

UPDATE PRCommodity2 
   SET prcm_Description = 'Micro greens',
       prcm_Description_ES = 'Hojas micro'
 WHERE prcm_CommodityID=383  AND prcm_AttributeID IS NULL AND prcm_GrowingMethodID IS NULL

UPDATE PRCommodity2 
   SET prcm_Description = REPLACE(prcm_Description, 'greens greens', 'greens'),
       prcm_Description_ES = REPLACE(prcm_Description_ES, 'hojas micro hojas', 'hojas micro')
 WHERE prcm_CommodityID=383  
   AND (prcm_AttributeID IS NOT NULL OR prcm_GrowingMethodID IS NOT NULL)
Go

UPDATE PRCommodityTranslation SET prcx_Abbreviation = REPLACE(prcx_Abbreviation COLLATE Latin1_General_BIN, 'Rabebc', 'Bcrabe')
	WHERE prcx_abbreviation like '%rabe%'
UPDATE PRCommodityTranslation SET prcx_Abbreviation = REPLACE(prcx_Abbreviation COLLATE Latin1_General_BIN, 'rabebc', 'bcrabe')
	WHERE prcx_abbreviation like '%rabe%'
UPDATE PRCommodityTranslation SET prcx_Description = REPLACE(prcx_Description COLLATE Latin1_General_BIN, 'Rabe broccoli', 'Broccoli rabe')
	WHERE prcx_abbreviation like '%rabe%'
UPDATE PRCommodityTranslation SET prcx_Description = REPLACE(prcx_Description COLLATE Latin1_General_BIN, 'rabe broccoli', 'broccoli rabe')
	WHERE prcx_abbreviation like '%rabe%'
GO



--Defect 4282 - AUS changes
--Data correction to Alerts
UPDATE PRWebUserList SET 
	prwucl_Name = 'Alerts List'
WHERE 
	prwucl_TypeCode = 'AUS' AND prwucl_Name = 'Automatic Update Service List'

UPDATE PRWebUserList SET 
	prwucl_Name = 'Lista de Alertas'
WHERE 
	prwucl_TypeCode = 'AUS' AND prwucl_Name = 'Lista de actualizacion automática'

--AUS Widget rename
UPDATE PRWebUserWidget SET prwuw_WidgetCode='AlertCompaniesRecentKeyChanges' WHERE prwuw_WidgetCode='AUSCompaniesRecentKeyChanges'

DECLARE @capt_NextId int
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidget', 'AlertCompaniesRecentKeyChanges', 'Alert Companies With Recent Key Changes', 'Alert Companies With Recent Key Changes', -1, getdate(), -1, getdate())

exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'AlertCompaniesRecentKeyChanges', 'Alert Companies With Recent Key Changes', 'Alert Companies With Recent Key Changes', -1, getdate(), -1, getdate())

DELETE FROM CUSTOM_CAPTIONS WHERE capt_FamilyType='Choices' AND Capt_Family='PRWebUserWidget' AND capt_code='AUSCompaniesRecentKeyChanges'
DELETE FROM CUSTOM_CAPTIONS WHERE capt_FamilyType='Choices' AND Capt_Family='PRWebUserWidgetL' AND capt_code='AUSCompaniesRecentKeyChanges'
GO

UPDATE custom_captions SET Capt_US='Alerts List', Capt_ES='Lista de Alertas' 
WHERE capt_family='PRWebUserListName' AND capt_code='Name_AUS'

