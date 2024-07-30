--8.6 Release
USE CRM

EXEC usp_DeleteCustom_Tab 'find', '3rd Party News'
EXEC usp_DeleteCustom_Tab 'find', 'External News Articles'
GO

EXEC usp_AccpacCreateTextField 'PRWebSiteVisitor', 'prwsv_SubmitterName', 'Submitter Name', 50, 200
GO

--Defect 5767 - rebuild interactions page(s)
UPDATE custom_tabs SET Tabs_CustomFileName='PRInteraction/PRCompanyInteractions.asp' WHERE tabs_entity='company' and Tabs_Caption='Interactions' and tabs_action='customfile' --previously was 'InteractionRedirect.asp'
--revert line -- UPDATE custom_tabs SET Tabs_CustomFileName='InteractionRedirect.asp' WHERE tabs_entity='company' and Tabs_Caption='Interactions' and tabs_action='customfile'
GO

EXEC usp_DeleteCustom_ScreenObject 'CompanyInteractionGrid'
EXEC usp_AddCustom_ScreenObjects 'CompanyInteractionGrid', 'List', 'vListCommunication2', 'N', 0, 'vListCommunication2'
EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 10, 'comm_hasattachments', null, null, null, 'CENTER', null, 'Y', null, 'communication', 'comm_communicationid'
--EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 20, 'comm_action', null, 'Y', null, 'CENTER', null, 'N', null, null, null
EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 30, 'comm_datetime', null, 'Y', 'Y', null, null, null, null, null, null
EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 40, 'comm_action', null, 'Y', null, null, null, null, null, null, null
EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 50, 'pers_fullname', null, null, null, null, 'person', null, null, null, null
EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 60, 'comm_subject', null, 'N', null, null, 'custom', 'Y', null, 'PRGeneral/PRInteraction.asp', 'comm_communicationid'
EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 70, 'cmli_comm_userid', null, null, null, null, null, null, null, null
EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 80, 'comm_prcategory', null, 'Y', null, 'LEFT', null, null, null, null, null
EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 90, 'comm_prsubcategory', null, 'Y', null, 'LEFT', null, null, null, null, null
EXEC usp_AddCustom_Lists 'CompanyInteractionGrid', 100, 'comm_status', null, 'Y', null, 'CENTER', 'Communication', 'Y', 'Y', null, null

UPDATE custom_lists SET GriP_ViewMode='ATTACHMENT' WHERE GriP_GridName='CompanyInteractionGrid' AND GriP_ColName='comm_hasattachments'
UPDATE custom_lists SET GriP_ViewMode='GIF' WHERE GriP_GridName='CompanyInteractionGrid' AND GriP_ColName='comm_status'

GO


EXEC usp_DeleteCustom_ScreenObject 'PRCompanyInteractionFilterBox'
EXEC usp_AddCustom_ScreenObjects 'PRCompanyInteractionFilterBox', 'Screen', 'vListCommunication2', 'N', 0, 'vListCommunication2'
EXEC usp_AddCustom_Screens 'PRCompanyInteractionFilterBox', 40, 'Comm_secterr', 1, 1, 1, null
GO

--Defect 4579
EXEC usp_AccpacCreateCheckboxField 'PRWebUser', 'prwu_HideBRPurchaseConfirmationMsg', 'Hide BR Purchase Confirmation Msg'
GO

--Change PRCompanyExperian to not identity table
DECLARE @sql nvarchar(500)
DECLARE @table nvarchar(500) = 'PRCompanyExperian'
SELECT @sql = 'ALTER TABLE ' + @table 
		+ ' DROP CONSTRAINT ' + name + ';'
	  FROM sys.key_constraints
		WHERE [type] = 'PK'
		AND [parent_object_id] = OBJECT_ID(@table);
EXEC sp_executeSQL @sql;
GO

ALTER TABLE PRCompanyExperian
	ADD prcex_CompanyExperianID_new INT NOT NULL DEFAULT 0
GO
	
UPDATE PRCompanyExperian
	SET prcex_CompanyExperianID_new = prcex_CompanyExperianID
GO

ALTER TABLE PRCompanyExperian DROP COLUMN prcex_CompanyExperianID
GO

EXEC sp_RENAME 'PRCompanyExperian.prcex_CompanyExperianID_new', 'prcex_CompanyExperianID', 'COLUMN'
GO

ALTER TABLE [dbo].[PRCompanyExperian] ADD PRIMARY KEY CLUSTERED 
(
	[prcex_CompanyExperianID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

DECLARE @TableId int
DECLARE @MaxId int
SELECT @TableId = Bord_TableId FROM Custom_Tables NOLOCK WHERE Bord_Name = 'PRCompanyExperian'
SELECT @MaxId = MAX(prcex_CompanyExperianID) FROM PRCompanyExperian
SELECT @MaxId MaxId

UPDATE dbo.SQL_Identity SET Id_NextId = @MaxId + 1 WHERE Id_TableId = @TableId
UPDATE Rep_Ranges 
	SET Range_RangeStart = 60000,
	Range_RangeEnd = 69999,
	Range_NextRangeStart = 70000,
	Range_NextRangeEnd = 79999,
	Range_Control_NextRange = 80000
	WHERE Range_TableId = @TableId

--EXEC usp_AddCustom_Lists 'CommunicationToDoList', 43, 'prci_Timezone', null, 'Y', null, 'CENTER', null, null, null, null, null

--8.6 Release
USE CRM

--Defect 6769 lumber pricing
/*
	SELECT
		prod_productid, prod_name, prod_code, prod_productfamilyid, prod_prwebusers, prod_prserviceunits, prod_prwebaccesslevel, prod_industrytypecode, prod_purchaseinbbos, pric_pricingid, pric_productid, pric_price, pric_pricinglistid, prod_prdescription
	FROM NewProduct
		LEFT OUTER JOIN Pricing ON pric_PRoductID = prod_ProductID
	WHERE prod_code IN ('L100', 'L200', 'L300', 'L400')
	ORDER BY prod_code
*/

UPDATE NewProduct SET prod_prwebusers=1, prod_prserviceunits=0,
	prod_prdescription='<ul class="Bullets"><li>1 BBOS user license</li><li>0 Business Reports</li></ul>'
WHERE prod_code='L100' AND prod_productfamilyid=5
			
--Add new Pricing records for L100
INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp, pric_PriceCode)
						VALUES (87,             85 ,            675,        16002,          16002,              'Y',         -100,           GETDATE(),        -1,             GETDATE(),        GETDATE(),      null);

--L200			
UPDATE NewProduct SET prod_prwebusers=5, prod_prserviceunits=5, prod_PRWebAccessLevel = 400,
	prod_prdescription='<ul class="Bullets"><li>5 BBOS user licenses</li><li>5 Business Reports</li></ul>'
WHERE prod_code='L200' AND prod_productfamilyid=5
UPDATE Pricing SET pric_Price=1200 WHERE pric_pricingid=64

--change all L200 users access level from 500 to 400
UPDATE PRWebUser SET prwu_AccessLevel=400 WHERE prwu_WebUserID IN
		(SELECT DISTINCT prwu_WebUserID FROM PRWebUser WHERE
			prwu_hqid in (select prse_hqid from PRService where prse_Primary='Y' AND prse_ServiceCode='L200')
			AND prwu_AccessLevel is not null and prwu_AccessLevel=500)

UPDATE NewProduct SET prod_prwebusers=15, prod_prserviceunits=60,
	prod_prdescription='<ul class="Bullets"><li>15 BBOS user licenses</li><li>60 Business Reports</li></ul>'
WHERE prod_code='L300' AND prod_productfamilyid=5
UPDATE Pricing SET pric_Price=2000 WHERE pric_pricingid=65 --L300

DELETE FROM NewProduct WHERE prod_code='L400' AND prod_productfamilyid=5

--New LSTDLIC product for Lumber
DECLARE @Prod_ProductID int = 98
DELETE FROM NewProduct WHERE Prod_ProductID = @Prod_ProductID
INSERT INTO NewProduct
			 (Prod_ProductID,
				prod_Active,
				prod_UOMCategory,
				prod_name,
				prod_code,
				prod_productfamilyid,
				prod_PRWebAccess,
				prod_PRWebUsers,
				prod_PRWebAccessLevel,
				prod_PRSequence,
				prod_PRDescription, 
				prod_PRRecurring, 
				prod_PRServiceUnits,
				prod_IndustryTypeCode,
				prod_PRIsTaxed,
				prod_PurchaseInBBOS,
				prod_Name_ES,
				prod_PRDescription_ES,

				Prod_CreatedBy,
				Prod_CreatedDate,
				Prod_UpdatedBy,
				Prod_UpdatedDate,
				Prod_TimeStamp 
)
VALUES (@Prod_ProductID,
				'Y',
				6000,
				'Lumber Standard License', 
				'LSTDLIC', 
				6, 
				'Y',
				1,
				400,
				20,
				'Provides intermediate access to online features and allows you to search companies by phone, fax and E-mail, postal code, commodities, classifications and licenses (e.g. PACA, DRC, CFIA). View company affiliations and branches. Save your search criteria for future retrieval and export search results into Excel. Create and save notes with private feature on companies and people.',
				'Y',
				0,
				',L,',
				NULL,
				NULL,
				'Licencia Intermedia de BBOS (es)',
				'Proporciona acceso intermedio a las funciones en línea y le permite buscar compañías por teléfono, fax y correo electrónico, código postal, productos, clasificaciones y licencias (por ejemplo, PACA, DRC, CFIA). Visualiza las sucursales y afiliaciones de la compañía. Guarda sus criterios de búsqueda para una recuperación futura y exporta los resultados en Excel. Crea y guarda notas con funciones privadas sobre las compañías y las personas.',
				-1, GETDATE(),-1,GETDATE(),GETDATE());




UPDATE Pricing SET pric_price=25 WHERE pric_productID=95 --lumber ala-carte business report is now $25 instead of $10

--Privileges
	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE IndustryType='L' and AccessLevel=500 --Make lumber 500 (L300) be the same as 400 (L200) to start so that users moved to L200 from L300 will start with the same core privileges

	--now set specific privileges for L200 and L300
	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE Privilege='ReportNotes' AND IndustryType='L'  --L200 and L300
	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE Privilege='CompanySearchByHasNotes' AND IndustryType='L' --L200 and L300
	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE Privilege='Notes' AND IndustryType='L' --L200 and L300 (L200 limited to 75)
	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE Privilege='PersonSearchByNotes' AND IndustryType='L' --L200 and L300
	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE Privilege='CompanyDetailsCustomPage' AND IndustryType='L'  --L200 and L300

	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE Privilege='CompanySearchByWatchdogList' AND IndustryType='L'  --L200 and L300 have access
	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE Privilege='PersonSearchByWatchdogList' AND IndustryType='L' --L200 and L300 have access
	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE Privilege='WatchdogListAdd' AND IndustryType='L'  --L200 and L300 have access
	UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE Privilege='WatchdogListsPage' AND IndustryType='L'  --L200 and L300 have access

--SELECT
--	prod_productid, prod_name, prod_code, prod_productfamilyid, prod_prwebusers, prod_prserviceunits, prod_prwebaccesslevel, prod_industrytypecode, prod_purchaseinbbos, pric_pricingid, pric_productid, pric_price, pric_pricinglistid, prod_prdescription
--FROM NewProduct
--	LEFT OUTER JOIN Pricing ON pric_PRoductID = prod_ProductID
--WHERE prod_code IN ('L100', 'L200', 'L300', 'L400')
--ORDER BY prod_code


-- Defect 5763
--AdCampaignAdKYC
EXEC usp_DeleteCustom_ScreenObject 'AdCampaignAdKYC'
EXEC usp_AddCustom_ScreenObjects 'AdCampaignAdKYC', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 1, 'pradc_CompanyID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 3, 'pradc_AdCampaignHeaderID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 4, 'pradc_Name', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 5, 'pradc_AdCampaignType', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 10, 'pradc_KYCEdition', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 20, 'pradc_KYCCommodityID', 0, 1, 1, 0 

EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 25, 'pradc_AdSize', 0, 1, 1, 0  --new

EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 30, 'pradc_Placement', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 40, 'pradc_Premium', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 50, 'pradc_Cost', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 60, 'pradc_Discount', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 70, 'pradc_Notes', 1, 1, 2, 0 -- was 2 cols

EXEC usp_AddCustom_Screens 'AdCampaignAdKYC', 80, 'pradc_PlacementInstructions', 0, 1, 3, 0 -- new

		
--Defect 4566 - credit sheet
EXEC usp_AccpacCreateCheckboxField 'PRCreditSheetBatch', 'prcsb_HighlightMsg', 'Highlight Marketing Message'
GO


--Defect 4199
--additional reports are going to be $25 a report. Please reflect this in the system and also on this page: BusReportPurchase.aspx  (So 5 reports would be $125, etc.)
UPDATE Pricing SET Pric_UpdatedBy=-1, Pric_UpdatedDate=GETDATE(), pric_price=5*25.00 WHERE pric_pricingid=74
UPDATE Pricing SET Pric_UpdatedBy=-1, Pric_UpdatedDate=GETDATE(), pric_price=10*25.00 WHERE pric_pricingid=75
UPDATE Pricing SET Pric_UpdatedBy=-1, Pric_UpdatedDate=GETDATE(), pric_price=15*25.00 WHERE pric_pricingid=76
UPDATE Pricing SET Pric_UpdatedBy=-1, Pric_UpdatedDate=GETDATE(), pric_price=20*25.00 WHERE pric_pricingid=77
UPDATE Pricing SET Pric_UpdatedBy=-1, Pric_UpdatedDate=GETDATE(), pric_price=40*25.00 WHERE pric_pricingid=78