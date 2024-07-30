--8.17 Release DataCorrections
UPDATE PRCompanySearch
   SET prce_WordPressSlug = CASE comp_PRIndustryType WHEN 'L' THEN '/services/find-companies/profile/' ELSE '/find-produce-companies/profile/' END + dbo.ufn_PrepareSlugValue(prcn_Country) +  dbo.ufn_PrepareSlugValue(ISNULL(prst_Abbreviation, prst_State)) + dbo.ufn_PrepareSlugValue(prci_City) + dbo.ufn_PrepareSlugValue(comp_Name) + CAST(comp_CompanyID as varchar(10)) + '/'
  FROM Company
       INNER JOIN vPRLocation ON comp_PRListingCityId = prci_CityID
 WHERE comp_PRListingStatus <> 'D' 
   AND prcse_CompanyID = comp_CompanyID
Go

--9.0 Release DataCorrections
--DELETE FROM NewProduct WHERE prod_ProductID=108
INSERT INTO NewProduct
	(Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,prod_PRDescription,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (108,'Y',6000,'Business Report','BRF',2, ',P,T,S,', 140, '<div style="font-weight:bold">Blue Book Business Report excluding Equifax Credit Information</div><p style="margin-top:0em">Creditors—such as sellers, transporters and suppliers—use this report type for performing a high-level connection/prospect evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick & easy to reach informed decisions.</p><p>The Business Report includes: basic company contact information such as Blue Book ID#, company name, listing location, addresses, phones, faxes, e-mails, web URLs, ownership, and alternate trade names. Also included - if available/applicable - are current headquarter rating & rating definition, affiliated businesses, branch locations, headquarter rating trend, recent company developments, bankruptcy events, business background, people background, business profile, financial information, and year-to-date trade report summary. Select credit information such as public record information will be included with your Business Report, as available/applicable.</p>',-1,GETDATE(),-1,GETDATE(),GETDATE());

--DELETE FROM Pricing WHERE pric_ProductID=108
INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
VALUES (88, 108, 0, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());

GO


UPDATE NewProduct SET prod_PRBackgroundChecks=1 WHERE prod_ProductID=200
UPDATE NewProduct SET prod_PRBackgroundChecks=5 WHERE prod_ProductID=201
UPDATE NewProduct SET prod_PRBackgroundChecks=15 WHERE prod_ProductID=202
Go

INSERT INTO PRBackgroundCheckAllocation (prbca_HQID, prbca_CompanyID, prbca_AllocationTypeCode, prbca_Allocation, prbca_Remaining, prbca_StartDate, prbca_ExpirationDate, prbca_CreatedBy, prbca_CreatedDate)
SELECT prse_HQID, prse_CompanyID, 'M', CASE prse_ServiceCode WHEN 'BASIC' THEN 1 WHEN 'STANDARD' THEN 5 WHEN 'PREMIUM' THEN 15 END, CASE prse_ServiceCode WHEN 'BASIC' THEN 1 WHEN 'STANDARD' THEN 5 WHEN 'PREMIUM' THEN 15 END, '2024-01-01', '2025-01-01', 1, GETDATE()
  FROM PRService
 WHERE prse_Primary='Y'
   AND prse_ServiceCode IN ('BASIC', 'STANDARD', 'PREMIUM')
   AND prse_HQID NOT IN (SELECT prbca_HQID FROM PRBackgroundCheckAllocation)
GO


UPDATE NewProduct SET prod_name='Basic Service', 
						prod_Name_ES='Servicio Básico'
WHERE Prod_ProductID=200 AND prod_code='BASIC'

UPDATE NewProduct SET prod_name='Standard Service', 
						prod_Name_ES='Servicio Estándar',
						prod_PRDescription='<ul class="Bullets"><li>8 Standard Blue Book Online User Licenses</li><li>Unlimited Blue Book Business Reports</li><li>25 Experian Business Reports</li><li>View &amp; Search Company Contacts</li><li><b><i>Complimentary</i></b> Logo in Company Profile</li></ul>',
						prod_PRDescription_ES='<ul class="Bullets"><li>8 licencias de usuario estándar del Blue Book Online</li><li>Informes comerciales ilimitados de Blue Book</li><li>25 Informes Experian sobre empresa</li><li>Ver y Buscar Contactos de la Empresa</li><li>Logotipo <b>Gratuito</b> en el Perfil de la Empresa</li></ul>'
WHERE Prod_ProductID=201 AND prod_code='STANDARD'

UPDATE NewProduct SET prod_name='Premium Service',
						prod_Name_ES='Servicio Premium',
						prod_PRDescription='<ul class="Bullets"><li>Unlimited Premium Blue Book Online User Licenses</li><li>Unlimited Blue Book Business Reports</li><li>50 Experian Business Reports</li><li>View &amp; Search Company Contacts</li><li><b><i>Complimentary</i></b> Logo in Company Profile</li><li>Blue Book Digital Ad 10% Discount</li></ul>',
						prod_PRDescription_ES='<ul class="Bullets"><li>Licencias de usuario ilimitadas Premium Blue Book Online</li><li>Informes comerciales ilimitados de Blue Book</li><li>50 Informes Experian sobre empresas</li><li>Ver y Buscar Contactos de la Empresa</li><li>Logotipo <b>Gratuito</b> en el Perfil de la Empresa</li><li>Anuncio Digital en el Libro Azul 10% de Descuento</li></ul>'
WHERE Prod_ProductID=202 AND prod_code='PREMIUM'

GO

