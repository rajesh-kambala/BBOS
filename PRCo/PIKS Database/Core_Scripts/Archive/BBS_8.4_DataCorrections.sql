--8.4 Release
USE CRM

--***************    BEGIN    SERIES 250 CHANGES  *****************************
--5.1.1	PRBBOSPrivilege
UPDATE PRBBOSPrivilege SET AccessLevel=700 WHERE AccessLevel=500
UPDATE PRBBOSPrivilege SET AccessLevel=500 WHERE AccessLevel=400
UPDATE PRBBOSPrivilege SET AccessLevel=400 WHERE AccessLevel=300
UPDATE PRBBOSPrivilege SET AccessLevel=300 WHERE AccessLevel=250
UPDATE PRBBOSPrivilege SET AccessLevel=200 WHERE AccessLevel=200
UPDATE PRBBOSPrivilege SET AccessLevel=100 WHERE AccessLevel=50

INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('P', 600, 'ViewPerformanceIndicators', NULL, 0, 0)
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('T', 600, 'ViewPerformanceIndicators', NULL, 0, 0)
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('S', 600, 'ViewPerformanceIndicators', NULL, 0, 0)

--select * from prbbosprivilege where privilege='ViewPerformanceIndicators'

--5.1.2	NewProduct - Update to use the new BBOS Access Codes
UPDATE NewProduct SET prod_PRWebAccessLevel=700 WHERE prod_PRWebAccessLevel=500
UPDATE NewProduct SET prod_PRWebAccessLevel=500 WHERE prod_PRWebAccessLevel=400
UPDATE NewProduct SET prod_PRWebAccessLevel=400 WHERE prod_PRWebAccessLevel=300
UPDATE NewProduct SET prod_PRWebAccessLevel=300 WHERE prod_PRWebAccessLevel=250
UPDATE NewProduct SET prod_PRWebAccessLevel=200 WHERE prod_PRWebAccessLevel=200

--5.1.2.2	Insert the record for the Series 250 Membership.  The following is to-be-provided:
/*�	MAS Code
�	# User Licenses
�	# of Business Reports
�	Description for BBOS and Marketing Site Purchase Page (English & Spanish) */

DECLARE @Prod_ProductID int = 96
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
				'Blue Book Service: 250', 
				'BBS250', 
				5, 
				'Y',
				7,
				600,
				45,
				'<ul class="Bullets"><li>7 Blue Book Online User Licenses</li><li>40 Business Reports</li></ul>',
				'Y',
				40,
				',P,T,S,',
				'Y',
				'Y',
				'Servicio de Blue Book: 250',
				'<ul class="Bullets"><li>7 licencias de usuarios en línea de Blue Book</li><li>40 informes comerciales</li></ul>',

				-1, GETDATE(),-1,GETDATE(),GETDATE());

DECLARE @Pric_PricingID int = 81
DELETE FROM Pricing WHERE Pric_PricingId = @Pric_PricingID
INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, 
pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
 VALUES (@Pric_PricingID, @Prod_ProductID, 1375, 16002, 16002, 'Y', -100, GETDATE(), -1, GETDATE(), GETDATE());
GO

DECLARE @Prod_ProductID int = 97
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
				'Advanced Plus BBOS License', 
				'ADVPLIC', 
				6, 
				'Y',
				1,
				600,
				35,
				'Provides advanced plus access to online features and allows you to search newly listed businesses and industry personnel. Search companies by radius and terminal market. View and search company updates and save important contact information in a vCard format in Outlook.',
				'Y',
				0,
				',P,T,S,',
				NULL,
				NULL,
				'Licencias Avanzadas Plus de BBOS',
				'Proporciona acceso plus avanzado a las funciones en línea y le permite buscar empresas recién incluidas y personal de la industria. Busca compañías por radio y central de mercados. Visualiza y busca actualizaciones de la compañía y guarda información importante de contacto en un formato vCard en Outlook.',

				-1, GETDATE(),-1,GETDATE(),GETDATE());

DECLARE @Pric_PricingID int = 82
DELETE FROM Pricing WHERE Pric_PricingId = @Pric_PricingID
INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, 
pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
 VALUES (@Pric_PricingID, @Prod_ProductID, 155, 16002, 16002, 'Y', -100, GETDATE(), -100, GETDATE(), GETDATE());
GO

--SELECT * FROM NewProduct WHERE Prod_ProductID = @Prod_ProductID
--SELECT * FROM Pricing WHERE Pric_PricingID = @Pric_PricingID

--5.1.3 Update to use the new BBOS Access Levels (prwu_AccessLevel)
UPDATE PRWebUser SET prwu_AccessLevel=700 WHERE prwu_AccessLevel=500 --2832
UPDATE PRWebUser SET prwu_AccessLevel=500 WHERE prwu_AccessLevel=400 --8835
UPDATE PRWebUser SET prwu_AccessLevel=400 WHERE prwu_AccessLevel=300 --1992
UPDATE PRWebUser SET prwu_AccessLevel=300 WHERE prwu_AccessLevel=250 --140
UPDATE PRWebUser SET prwu_AccessLevel=200 WHERE prwu_AccessLevel=200 --1372
UPDATE PRWebUser SET prwu_AccessLevel=100 WHERE prwu_AccessLevel=50 --1372

UPDATE NewProduct SET prod_PRDescription='<ul class="Bullets"><li>3 Standard Blue Book Online User Licenses</li><li>10 Business Reports</li></ul>',
prod_PRDescription_ES='<ul class="Bullets"><li>3 Licencias de Usuario de Blue Book Estándares</li><li>10 informes comerciales</li></ul>'
WHERE prod_UOMCategory=6000 AND prod_code='BBS150'

UPDATE NewProduct SET prod_PRDescription='<ul class="Bullets"><li>5 Advanced Blue Book Online User Licenses</li><li>20 Business Reports</li></ul>',
prod_PRDescription_ES='<ul class="Bullets"><li>5 Licencias de Usuario de Blue Book Avanzadas</li><li>20 informes comerciales</li></ul>'
WHERE prod_UOMCategory=6000 AND prod_code='BBS200'

UPDATE NewProduct SET prod_PRDescription='<ul class="Bullets"><li>7 Advanced Plus Blue Book Online User Licenses</li><li>40 Business Reports</li></ul>',
prod_PRDescription_ES='<ul class="Bullets"><li>7 Licencias de Usuario de Blue Book Avanzadas Plus</li><li>40 informes comerciales</li></ul>'
WHERE prod_UOMCategory=6000 AND prod_code='BBS250'

UPDATE NewProduct SET prod_PRDescription='<ul class="Bullets"><li>10 Premium Blue Book Online User Licenses</li><li>85 Business Reports</li></ul>',
prod_PRDescription_ES='<ul class="Bullets"><li>10 Licencias de Usuario de Blue Book Premium</li><li>85 informes comerciales</li></ul>'
WHERE prod_UOMCategory=6000 AND prod_code='BBS300'


--***************    END     SERIES 250 CHANGES  *****************************


--BBIDs Approved by Kathi to have Year-Round Advertiser flag set
UPDATE PRCompanyInfoProfile
SET prc5_PRARYearRoundBPAdvertiser='Y'
WHERE prc5_CompanyId in (120506,170926,209355,342817,301832,207043,302589,161417,187846,203682,117489,169939,116171,151227,155976,101235,154447,115999,285114,196583,107658,260906,284699,145898,172034,286516,260549,262433,261831,255041,166464,259390,301644,171361,126385,301097,233534,169094,170906,205713,170470,172729,189807,129930,283014,143492,332163,104644,115739,168576,293121,186849,300457,166519,164545,115772,188398,153708,206204,209734,166527,209079,149020,118108,115731,190496,197829,166654,203522,104793,101402,210074,126889,168619,280401,150285,145458,189383,254788,115824,153854)

UPDATE NewProduct SET prod_PurchaseInBBOS = NULL WHERE prod_code = 'BBS350' AND prod_productfamilyid = 5

--Acai had the wrong article number
UPDATE PRKYCCommodity SET prkycc_ArticleID=5340 WHERE prkycc_ArticleID=5426 and prkycc_PostName='Acai'


--Defect 4653 - remove CFIA from prli_Type dropdown
DELETE FROM Custom_Captions WHERE Capt_FamilyType='Choices' AND Capt_Family='prli_Type' AND Capt_Code='CFIA'

UPDATE Custom_Captions SET capt_US='Reported PACA license reinstated.' WHERE capt_family='prrn_Name' AND capt_Code = '(151)' --previously was Reported PACA or CFIA license reinstated.
UPDATE Custom_Captions SET capt_US='Reported PACA license suspended or terminated with sanctions imposed against the company.' WHERE capt_family='prrn_Name' AND capt_Code = '(152)' --previously was Reported PACA or CFIA license suspended or terminated with sanctions imposed against the company.
UPDATE Custom_Captions SET capt_US='Reported PACA license revoked.' WHERE capt_family='prrn_Name' AND capt_Code = '(153)' --previously was Reported PACA or CFIA license revoked.

ALTER TABLE PRCompanyLicense DISABLE TRIGGER ALL
DELETE FROM PRCompanyLicense WHERE prli_Type = 'CFIA'
ALTER TABLE PRCompanyLicense ENABLE TRIGGER ALL
Go

UPDATE PRCompanySearch
   SET prcse_NameMatch = dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_Name)),
       prcse_CorrTradestyleMatch = dbo.ufn_GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PRCorrTradestyle))
  FROM Company
 WHERE prcse_CompanyID = comp_CompanyID
Go

-- Snow Peas, Peas, Plutos, Plums, Rutabagas, and turnips changes to point to combined WordPress articles
UPDATE PRKYCCommodity SET
	prkycc_HasAd = NULL
WHERE prkycc_PostName='Snow Peas'

UPDATE PRKYCCommodity SET
	prkycc_PostName = 'Peas &amp; Snow Peas',
	prkycc_ArticleID = -1
WHERE prkycc_PostName IN ('Peas', 'Snow Peas')

UPDATE PRKYCCommodity SET
	prkycc_HasAd = NULL
WHERE prkycc_PostName='Pluots'
UPDATE PRKYCCommodity SET
	prkycc_PostName = 'Plums &amp; Pluots',
	prkycc_ArticleID = -2
WHERE prkycc_PostName IN ('Plums', 'Pluots')


DELETE FROM PRKYCCommodity WHERE prkycc_KYCCommodityID=6284 AND prkycc_PostName='Rutabagas' AND prkycc_CommodityId=462
DELETE FROM PRKYCCommodity WHERE PRKYCC_PostName='Turnips & Rutabagas' AND prkycc_ArticleID = 0

UPDATE PRKYCCommodity SET prkycc_HasAd = NULL WHERE prkycc_PostName='Rutabagas' and prkycc_CommodityID=462
UPDATE PRKYCCommodity SET prkycc_HasAd = NULL WHERE prkycc_PostName='Rutabagas' and prkycc_CommodityID=462
UPDATE PRKYCCommodity SET prkycc_HasAd = NULL WHERE prkycc_PostName='Rutabagas' and prkycc_CommodityID=462

UPDATE PRKYCCommodity SET
	prkycc_PostName = 'Turnips &amp; Rutabagas',
	prkycc_ArticleID = -3
WHERE prkycc_PostName IN ('Rutabagas', 'Turnips')

--Preserve page impressions to new article ID for combined articles
UPDATE PRPublicationArticleRead SET prpar_PublicationArticleID = -1 WHERE prpar_publicationarticleid in (127,157) --Peas & Snow Peas
UPDATE PRPublicationArticleRead SET prpar_PublicationArticleID = -2 WHERE prpar_publicationarticleid in (137,139) --Plums & Plutos
UPDATE PRPublicationArticleRead SET prpar_PublicationArticleID = -3 WHERE prpar_publicationarticleid in (4973,177) --Turnips & Rutabagas

UPDATE NewProduct SET
	prod_name = 'Standard BBOS License', 
	prod_name_ES='Licencia Estándar de BBOS'
WHERE prod_name = 'Intermediate BBOS License'

--Add KYC Commodities Cassava and Broccoli Rabe
UPDATE PRKYCCommodity SET prkycc_ArticleID=10969, prkycc_CommodityID=439
WHERE prkycc_PostName = 'Cassava'
UPDATE PRCommodity SET prcm_PublicationArticleID =10969, prcm_KYCPostTitle='Cassava'
WHERE prcm_CommodityId=439

UPDATE PRKYCCommodity SET prkycc_ArticleID=10952, prkycc_CommodityID=347, prkycc_PostName='Broccoli Rabe',prkycc_HasAd='Y'
WHERE prkycc_CommodityID=347
UPDATE PRCommodity SET prcm_PublicationArticleID =10969, prcm_KYCPostTitle='Broccoli Rabe'
WHERE prcm_CommodityId=347

