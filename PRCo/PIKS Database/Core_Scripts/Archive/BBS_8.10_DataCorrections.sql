--8.10 Release
USE CRM

--DEFECT 5766
--Ensure that all digital Ads have an end time of 23:59:59
UPDATE pradc
	SET pradc.pradc_EndDate = DATETIMEFROMPARTS(
		DATEPART(year, pradc.pradc_EndDate),
		DATEPART(month, pradc.pradc_EndDate),
		DATEPART(day, pradc.pradc_EndDate),
		23, 59, 59, 0)
	FROM PRAdCampaign pradc 
		inner join PRAdCampaignHeader on pradch_adcampaignheaderid = pradc_AdCampaignHeaderID
	where
		datepart(hour, pradc_EndDate) <> 23
		and pradch_TypeCode = 'D'

--DEFECT 5758
--CRM/MAS: Change Trial Memberships to have Zero Business Reports
--Per MDE 8//22/19 - Trial Membership licenses should not have any business reports associated with them. - We can always add in reports manually to a trial, if needed.
UPDATE NewProduct SET prod_PRServiceUnits=0, Prod_UpdatedDate=GETDATE(), Prod_UpdatedBy=-1 WHERE prod_ProductID=68 --Trial Access License TRLLIC

--6/1/2021 change for Fruit Juice and Vegetable Juice
INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
	VALUES (1530, 'Fruit Juice', 'Fjuice', 37, 37, 2, 'Fruit,Fruit Juice', 'F,Fjuice', 'Fruit Juice', 'Fruit Juice', 1195, 3, GETDATE(), 3, GETDATE(), GETDATE());
INSERT INTO PRCommodity (prcm_CommodityID, prcm_Name, prcm_CommodityCode, prcm_RootParentID, prcm_ParentID, prcm_Level, prcm_PathNames, prcm_PathCodes, prcm_ShortDescription, prcm_FullName, prcm_DisplayOrder, prcm_CreatedBy, prcm_CreatedDate, prcm_UpdatedBy, prcm_UpdatedDate, prcm_Timestamp)
	VALUES (1535, 'Vegetable Juice', 'Vjuice', 291, 291, 2, 'Vegetable,Vegetable Juice', 'V,Vjuice', 'Vegetable Juice', 'Vegetable Juice', 4565, 3, GETDATE(), 3, GETDATE(), GETDATE());
UPDATE PRCommodity SET prcm_Name_ES ='Jugo de Fruta', prcm_FullName_ES ='Jugo de Fruta' WHERE prcm_CommodityCode = 'Fjuice'
UPDATE PRCommodity SET prcm_Name_ES ='Jugo de Vegetal', prcm_FullName_ES ='Jugo de Vegetal' WHERE prcm_CommodityCode = 'Vjuice'

DECLARE @NextID int
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 37, 1530, -1, GETDATE(), -1, GETDATE(), GETDATE())
EXEC usp_GetNextId 'PRCommodityCategory', @NextID output
	INSERT INTO PRCommodityCategory(prcomcat_CommodityCategoryId, prcomcat_ParentId, prcomcat_CommodityId, prcomcat_CreatedBy, prcomcat_CreatedDate, prcomcat_UpdatedBy, prcomcat_UpdatedDate, prcomcat_TimeStamp)
	VALUES(@NextID, 291, 1535, -1, GETDATE(), -1, GETDATE(), GETDATE())
GO

EXEC usp_PopulatePRCommodity2
GO

UPDATE PRCommodityTranslation SET prcx_Abbreviation = REPLACE(prcx_Abbreviation COLLATE Latin1_General_BIN, 'Fj', 'Fjuice')
	WHERE prcx_description = 'Fruit Juice'
UPDATE PRCommodityTranslation SET prcx_Abbreviation = REPLACE(prcx_Abbreviation COLLATE Latin1_General_BIN, 'Vj', 'Vjuice')
	WHERE prcx_description = 'Vegetable Juice'
GO