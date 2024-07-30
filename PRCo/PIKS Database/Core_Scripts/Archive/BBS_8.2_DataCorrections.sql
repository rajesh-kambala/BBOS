--8.2 Release

--DEFECT 2521
UPDATE custom_captions
SET Capt_US = 'Supply and Service', Capt_ES = 'Suministro y Servicio'
WHERE Capt_Family='BBOSSearchIndustryType' AND Capt_Code='S'


--DEFECT 4453
UPDATE newproduct SET prod_PRDescription=   '<div style="font-weight:bold">Blue Book Business Report including Experian Credit Information</div><p style="margin-top:0em">Creditors such as sellers, transporters and suppliers use this report type for performing a high-level account evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick &amp; easy to make informed decisions.</p><p>The Business Report includes, if available/applicable:<br/><ul class=''ul-2col''><li>&bull; Blue Book ID#</li><li>&bull; Company name</li><li>&bull; Listing location</li><li>&bull; Addresses</li><li>&bull; Phones</li><li>&bull; Faxes</li><li>&bull; E-mails &amp; website</li><li>&bull; Principals &amp; titles</li>	<li>&bull; Current company rating & rating definition</li><li>&bull; Current Blue Book Score and industry average</li><li>&bull; Recent business developments</li><li>&bull; Business profile &amp; background</li><li>&bull; Bankruptcy events</li><li>&bull; Personnel background</li><li>&bull; Last three financial statements provided</li><li>&bull; Year-to-date trade report summary</li><li>&bull; Previous two calendar years of trade reports</li><li>&bull; Trade report details for the past 18 months</li><li>&bull; Commodities handled</li><li>&bull; How the company operates</li><li>&bull; Annual volume</li><li>&bull; Alternate trade names</li><li>&bull; Affiliated businesses</li><li>&bull; Branch locations</li></ul><br/>Rating information is provided in easy-to-interpret tables and graphs. <br/><br/>Select credit information such as public record information, trade payment/legal filings, and business facts provided by <span style="font-weight:bold">Experian</span>, will be included with your Business Report, as available/applicable.<br/><br/> When used in conjunction with Blue Book data, information provided by <span style="font-weight:bold">Experian</span> can help provide a comprehensive financial picture of a company as a whole, including financial activities outside of the produce industry.</p>' WHERE prod_productid=47
UPDATE newproduct SET prod_PRDescription_ES='<div style="font-weight:bold">Informe de Negocios de Blue Book e Información Crediticia de Experian incluido</div><p style="margin-top:0em">Los acreedores como vendedores, transportistas y proveedores utilizan este tipo de informe para realizar una evaluación de cuenta de alto nivel, donde normalmente existe un interés específico en los hechos actuales y de tendencia, como las experiencias de pago y las prácticas comerciales. La presentación tabular y gráfica de la información de calificación de la compañía hace que sea fácil y rápido tomar decisiones informadas.</p><p>El Informe de Negocios incluye, si está disponible/aplicable:<br/><ul class=''ul-2col''><li>&bull; #ID de Blue Book</li><li>&bull; Nombre de empresa</li><li>&bull; Ubicación del listado</li><li>&bull; Direcciones</li><li>&bull; Teléfonos</li><li>&bull; Faxes</li><li>&bull; E-mails y sitio web</li><li>&bull; Directores y títulos</li><li>&bull; Calificación actual de la compañía con definición</li><li>&bull; El Puntaje Blue Book actual y promedio de la industria</li><li>&bull; Desarrollos de negocios recientes</li><li>&bull; Perfil Empresarial y antecedentes</li><li>&bull; Eventos de bancarrota</li><li>&bull; Antecedentes de personal</li><li>&bull; Últimos tres estados financieros proporcionados</li><li>&bull; Resumen del informe de comercio anual hasta la fecha</li><li>&bull; Dos años anteriores de informes comerciales</li><li>&bull; Detalles de informes comerciales de los últimos 18 meses</li><li>&bull; Productos manejados</li><li>&bull; Cómo opera la compañía</li><li>&bull; Volumen anual</li><li>&bull; Nombres comerciales alternativos</li><li>&bull; Empresas afiliadas</li><li>&bull; Ubicaciones de sucursales</li></ul><br/>La información de la calificación se proporciona en tablas y gráficos fáciles de interpretar.<br/><br/>La información de crédito seleccionada, como la información del registro público, el pago comercial/presentaciones legales y los hechos comerciales proporcionados por <span style="font-weight:bold">Experian</span>, se incluirán en su Informe comercial, como sean disponible/aplicable. <br/><br/> Cuando se utiliza junto con los datos de Blue Book, la información provista por <span style="font-weight:bold">Experian</span> puede ayudar a proporcionar una imagen financiera integral de una empresa en su conjunto, incluidas las actividades financieras fuera de la industria. </p>' WHERE prod_productid=47

UPDATE newproduct SET prod_PRDescription='<div style="font-weight:bold">Blue Book Business Report including Experian Credit Information</div><p style="margin-top:0em">Creditors such as sellers, transporters and suppliers use this report type for performing a high-level connection/prospect evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick & easy to reach informed decisions.</p><p>The Business Report includes: basic company contact information such as Blue Book ID#, company name, listing location, addresses, phones, faxes, e-mails, web URLs, ownership, and alternate trade names. Also included - if available/applicable - are current headquarter rating & rating definition, affiliated businesses, branch locations, headquarter rating trend, recent company developments, bankruptcy events, business background, people background, business profile, financial information, and year-to-date trade report summary. Select credit information such as public record information, trade payment/legal filings, and business facts provided by <span style="font-weight:bold">Experian</span>, will be included with your Business Report, as available/applicable. When used in conjunction with Blue Book data, information provided by <span style="font-weight:bold">Experian</span> can help provide a comprehensive financial picture of a company as a whole, including financial activities outside of the lumber industry.</p>' WHERE prod_productid=80
UPDATE newproduct SET prod_PRDescription_ES=NULL WHERE prod_productid=80
Go

--DEFECT 4511 - ITA same as NON-ITA
UPDATE newproduct SET prod_PRDescription=   '<div style="font-weight:bold">Blue Book Business Report including Experian Credit Information</div><p style="margin-top:0em">Creditors such as sellers, transporters and suppliers use this report type for performing a high-level account evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick &amp; easy to make informed decisions.</p><p>The Business Report includes, if available/applicable:<br/><ul class=''ul-2col''><li>&bull; Blue Book ID#</li><li>&bull; Company name</li><li>&bull; Listing location</li><li>&bull; Addresses</li><li>&bull; Phones</li><li>&bull; Faxes</li><li>&bull; E-mails &amp; website</li><li>&bull; Principals &amp; titles</li>	<li>&bull; Current company rating & rating definition</li><li>&bull; Current Blue Book Score and industry average</li><li>&bull; Recent business developments</li><li>&bull; Business profile &amp; background</li><li>&bull; Bankruptcy events</li><li>&bull; Personnel background</li><li>&bull; Last three financial statements provided</li><li>&bull; Year-to-date trade report summary</li><li>&bull; Previous two calendar years of trade reports</li><li>&bull; Trade report details for the past 18 months</li><li>&bull; Commodities handled</li><li>&bull; How the company operates</li><li>&bull; Annual volume</li><li>&bull; Alternate trade names</li><li>&bull; Affiliated businesses</li><li>&bull; Branch locations</li></ul><br/>Rating information is provided in easy-to-interpret tables and graphs. <br/><br/>Select credit information such as public record information, trade payment/legal filings, and business facts provided by <span style="font-weight:bold">Experian</span>, will be included with your Business Report, as available/applicable.<br/><br/> When used in conjunction with Blue Book data, information provided by <span style="font-weight:bold">Experian</span> can help provide a comprehensive financial picture of a company as a whole, including financial activities outside of the produce industry.</p>' WHERE prod_productid=94
UPDATE newproduct SET prod_PRDescription_ES='<div style="font-weight:bold">Informe de Negocios de Blue Book e Información Crediticia de Experian incluido</div><p style="margin-top:0em">Los acreedores como vendedores, transportistas y proveedores utilizan este tipo de informe para realizar una evaluación de cuenta de alto nivel, donde normalmente existe un interés específico en los hechos actuales y de tendencia, como las experiencias de pago y las prácticas comerciales. La presentación tabular y gráfica de la información de calificación de la compañía hace que sea fácil y rápido tomar decisiones informadas.</p><p>El Informe de Negocios incluye, si está disponible/aplicable:<br/><ul class=''ul-2col''><li>&bull; #ID de Blue Book</li><li>&bull; Nombre de empresa</li><li>&bull; Ubicación del listado</li><li>&bull; Direcciones</li><li>&bull; Teléfonos</li><li>&bull; Faxes</li><li>&bull; E-mails y sitio web</li><li>&bull; Directores y títulos</li><li>&bull; Calificación actual de la compañía con definición</li><li>&bull; El Puntaje Blue Book actual y promedio de la industria</li><li>&bull; Desarrollos de negocios recientes</li><li>&bull; Perfil Empresarial y antecedentes</li><li>&bull; Eventos de bancarrota</li><li>&bull; Antecedentes de personal</li><li>&bull; Últimos tres estados financieros proporcionados</li><li>&bull; Resumen del informe de comercio anual hasta la fecha</li><li>&bull; Dos años anteriores de informes comerciales</li><li>&bull; Detalles de informes comerciales de los últimos 18 meses</li><li>&bull; Productos manejados</li><li>&bull; Cómo opera la compañía</li><li>&bull; Volumen anual</li><li>&bull; Nombres comerciales alternativos</li><li>&bull; Empresas afiliadas</li><li>&bull; Ubicaciones de sucursales</li></ul><br/>La información de la calificación se proporciona en tablas y gráficos fáciles de interpretar.<br/><br/>La información de crédito seleccionada, como la información del registro público, el pago comercial/presentaciones legales y los hechos comerciales proporcionados por <span style="font-weight:bold">Experian</span>, se incluirán en su Informe comercial, como sean disponible/aplicable. <br/><br/> Cuando se utiliza junto con los datos de Blue Book, la información provista por <span style="font-weight:bold">Experian</span> puede ayudar a proporcionar una imagen financiera integral de una empresa en su conjunto, incluidas las actividades financieras fuera de la industria. </p>' WHERE prod_productid=94


--DEFECT 
UPDATE Custom_Captions SET Capt_US = 'Produce Business Magazine' WHERE capt_family = 'ProduceHowLearned' AND Capt_Code = 'Produce Busines'
UPDATE Custom_Captions SET Capt_US = 'The Produce News' WHERE capt_family = 'ProduceHowLearned' AND Capt_Code = 'Produce News'
DELETE FROM Custom_Captions WHERE capt_family = 'ProduceHowLearned' AND capt_code='PMA Fresh Magazine'
Go

--DEFECT 4320
UPDATE Company SET comp_PRPublishBBScore='Y' WHERE comp_CompanyID NOT IN (157221, 324407, 329729, 332493, 335752, 340815, 107593, 110823, 103173, 339217 )
Go

-- DEFECT 4562
UPDATE PRListing
   SET prlst_Listing = dbo.ufn_GetListingFromCompany(prlst_CompanyID, 0, 0),
		prlst_UpdatedDate = GETDATE(),
		prlst_UpdatedBy = 1
 WHERE prlst_CompanyID IN (SELECT prcr_RightCompanyId 
							  FROM PRCompanyRelationship
							 WHERE prcr_Type IN ('27', '28')
							   AND prcr_Active = 'Y')
Go

-- PRWebUserWidgets
declare @capt_NextId int
exec usp_getNextId 'custom_captions', @capt_NextId output
DELETE FROM CUSTOM_CAPTIONS WHERE Capt_Family='PRWebUserWidget' 
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidget', 'CompaniesRecentlyViewed', 'Recently Viewed Companies', 'Compañías Vistas ', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidget', 'ListingsRecentlyPublished', 'Recently Published New Listings', 'Nuevas Compañias Publicadas Reciente', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidget', 'AUSCompaniesRecentKeyChanges', 'AUS Companies With Recent Key Changes', 'AUS Companies With Recent Key Changes', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidget', 'BlueBookScoreDistribution', 'Blue Book Score Distribution', 'Blue Book Score Distribution', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidget', 'IndustryPayTrends', 'Industry Pay Trends', 'Industry Pay Trends', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidget', 'IndustryMetricsSnapshot', 'Industry Metrics Snapshot', 'Industry Metrics Snapshot', -1, getdate(), -1, getdate())

-- PRWebUserWidgetsL (for lumber)
exec usp_getNextId 'custom_captions', @capt_NextId output
DELETE FROM CUSTOM_CAPTIONS WHERE Capt_Family='PRWebUserWidgetL' 
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'CompaniesRecentlyViewed', 'Recently Viewed Companies', 'Compañías Vistas ', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'ListingsRecentlyPublished', 'Recently Published New Listings', 'Nuevas Compañias Publicadas Reciente', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'AUSCompaniesRecentKeyChanges', 'AUS Companies With Recent Key Changes', 'AUS Companies With Recent Key Changes', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'BlueBookScoreDistribution', 'Blue Book Score Distribution', 'Blue Book Score Distribution', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'PRWebUserWidgetL', 'IndustryMetricsSnapshot', 'Industry Metrics Snapshot', 'Industry Metrics Snapshot', -1, getdate(), -1, getdate())


--default all users to primary 2 widgets
DELETE FROM PRWebUserWidget	

INSERT INTO PRWebUserWidget (prwuw_CreatedDate, prwuw_UpdatedDate, prwuw_TimeStamp, prwuw_WebUserID, prwuw_WidgetCode, prwuw_Sequence)
SELECT GETDATE(), GETDATE(), GETDATE(), prwu_WebUserID, 'CompaniesRecentlyViewed', 1
FROM PRWebUser WHERE prwu_Deleted IS NULL

INSERT INTO PRWebUserWidget (prwuw_CreatedDate, prwuw_UpdatedDate, prwuw_TimeStamp, prwuw_WebUserID, prwuw_WidgetCode, prwuw_Sequence)
SELECT GETDATE(), GETDATE(), GETDATE(), prwu_WebUserID, 'ListingsRecentlyPublished', 2
FROM PRWebUser WHERE prwu_Deleted IS NULL

--DEFECT 4508
UPDATE newproduct SET prod_name_es='Copia del Libro Azul', prod_prdescription_es='Disponible en forma impresa, el Libro Azul proporciona información detallada sobre productos, transporte y compañías proveedoras de servicios y suministros dentro de los EEUU, Canadá, México y otros lugares internacionales.' where prod_productid=17
UPDATE newproduct SET prod_name_es='Copia de Blueprints', prod_prdescription_es='Blueprints es una revista trimestral entregado como parte de la membresía de Blue Book. Cada edición incluye artículos y estudios de caso de negocios sobre temas relevantes en las siguientes áreas temáticas: relaciones comerciales de proveedores y clientes, prácticas comerciales, costumbres y reglas, problemas y resolución de conflictos, finanzas, crédito, recopilación, tecnología e información de los productos agrícola.' where prod_productid=18
UPDATE newproduct SET prod_name_es='Servicio de Actualización Express', prod_prdescription_es='Los Informes de Actualizaciones Express reflejan cambios importantes que se han producido a Listados del Libro Azul y se entregan diariamente. Las actualizaciones incluyen cambios en las siguientes categorías: Propiedad, licenciamiento, calificación, de personal e información de contacto.' where prod_productid=21
Go

--DEFECT 4563
--SELECT PLink_RecordID, PLink_Type, phon_PRPublish, phon_PRIsPhone, phon_PRIsFax  FROM vPRCompanyPhone WHERE phon_PRIsFax IS NULL AND phon_PRIsPhone IS NULL AND plink_type IS NOT NULL
	UPDATE 
		Phone
	SET 
		Phone.phon_PRIsFax = CASE WHEN plink_Type IN ('F', 'PF', 'SF', 'EFAX') THEN 'Y'	END,
		Phone.phon_PRIsPhone = CASE WHEN plink_Type NOT IN ('F', 'SF', 'EFAX') THEN 'Y'	END,
		Phone.phon_UpdatedBy = -1,
		Phone.phon_UpdatedDate = GETDATE()
	FROM
		Phone 
		INNER JOIN PhoneLink ON pLink_PhoneId = Phon_PhoneId AND (phon_PRIsFax IS NULL AND phon_PRIsPhone IS NULL) AND PLink_Type IS NOT NULL

--DEFECT 4349 - classification changes
--Change Procurement Office to a Level 2 Classification. This should also make this classification available for searching in BBOS. 
--Remove the following Classifications and reassign to the Level 2 classification: 
--Buying Office (level 3) - remove that and reassign  to Buying Office (level 2) (not sure why there were two). 
--Branch Buying Office (level 3) - remove and reassign  to Buying Office (level 2) 
--Seasonal Buying Office (level 3) - remove and reassign to Buying Office (level 2) 
--Repacker (level 3) - remove and reassign to Repacker (level 2) (not sure why there were two). 
--Branch Sales Office (level 3) - remove and reassign  to Sales Office (level 2) 
--District Sales Office (level 3) - remove and reassign  to Sales Office (level 2) 
--Division Sales Office (level 3) - remove and reassign  to Sales Office (level 2) 
--Regional Sales Office (level 3) - remove and reassign  to Sales Office (level 2) 
--Sales Office (level 3) - remove and reassign to Sales Office (level 2) (not sure why there were two). 

DECLARE @PROCUREMENT_OFFICE_3 int = 2100
DECLARE @PROCUREMENT_OFFICE_2 int = 2100
DECLARE @BUYING_OFFICE_3 int = 2090
DECLARE @BUYING_OFFICE_2 int = 130
DECLARE @BRANCH_BUYING_OFFICE_3 int = 2080
DECLARE @SEASONAL_BUYING_OFFICE_3 int = 2110
DECLARE @REPACKER_3 int = 2120
DECLARE @REPACKER_2 int = 310
DECLARE @SALES_OFFICE_3 int= 2180
DECLARE @SALES_OFFICE_2 int= 380
DECLARE @BRANCH_SALES_OFFICE_3 int= 2140
DECLARE @DISTRICT_SALES_OFFICE_3 int = 2150
DECLARE @DIVISION_SALES_OFFICE_3 int= 2160
DECLARE @REGIONAL_SALES_OFFICE_3 int= 2170

DECLARE @RUN_DATE datetime = GETDATE()
--SELECT * FROM PRClassification WHERE prcl_Name = 'Procurement Office'

--SELECT COUNT(*) BeforeCount_OldTable FROM PRCompanyClassification WHERE prc2_ClassificationId IN (
--	@BUYING_OFFICE_3,
--	@BRANCH_BUYING_OFFICE_3,
--	@SEASONAL_BUYING_OFFICE_3,
--	@REPACKER_3,
--	@BRANCH_SALES_OFFICE_3,
--	@DIVISION_SALES_OFFICE_3 ,
--	@REGIONAL_SALES_OFFICE_3 ,
--	@SALES_OFFICE_3 
--)

--Change Procurement Office to a Level 2 Classification. This should also make this classification available for searching in BBOS. 
--SELECT * FROM PRClassification WHERE prcl_Name = 'Procurement Office'
UPDATE PRClassification SET prcl_Level = 2, prcl_ParentId = 1, prcl_DisplayOrder=255, prcl_UpdatedBy=-1, prcl_UpdatedDate = @RUN_DATE WHERE prcl_ClassificationId = @PROCUREMENT_OFFICE_3 
 
--SELECT * FROM PRClassification WHERE prcl_parentid = 1
--SELECT * FROM PRClassification WHERE prcl_Name = 'Produce Buyer'

--Buying Office (level 3) - remove that and reassign  to Buying Office (level 2) (not sure why there were two). 
--SELECT * FROM PRClassification where prcl_Name = 'Buying Office'
--SELECT * FROM PRCompanyClassification WHERE prc2_ClassificationId = @BUYING_OFFICE_3
UPDATE PRCompanyClassification SET prc2_ClassificationId = @BUYING_OFFICE_2, prc2_UpdatedBy=-1, prc2_UpdatedDate=@RUN_DATE WHERE prc2_ClassificationId = @BUYING_OFFICE_3
DELETE FROM PRClassification WHERE prcl_ClassificationId = @BUYING_OFFICE_3

--Branch Buying Office (level 3) - remove and reassign  to Buying Office (level 2) 
--SELECT * FROM PRClassification where prcl_Name = 'Branch Buying Office'
--SELECT * FROM PRCompanyClassification WHERE prc2_ClassificationId = @BRANCH_BUYING_OFFICE_3
UPDATE PRCompanyClassification SET prc2_ClassificationId = @BUYING_OFFICE_2, prc2_UpdatedBy=-1, prc2_UpdatedDate=@RUN_DATE WHERE prc2_ClassificationId = @BRANCH_BUYING_OFFICE_3
DELETE FROM PRClassification WHERE prcl_ClassificationId = @BRANCH_BUYING_OFFICE_3

--Seasonal Buying Office (level 3) - remove and reassign to Buying Office (level 2) 
--SELECT * FROM PRClassification where prcl_Name = 'Seasonal Buying Office'
--SELECT * FROM PRCompanyClassification WHERE prc2_ClassificationId = @SEASONAL_BUYING_OFFICE_3
UPDATE PRCompanyClassification SET prc2_ClassificationId = @BUYING_OFFICE_2, prc2_UpdatedBy=-1, prc2_UpdatedDate=@RUN_DATE WHERE prc2_ClassificationId = @SEASONAL_BUYING_OFFICE_3
DELETE FROM PRClassification WHERE prcl_ClassificationId = @SEASONAL_BUYING_OFFICE_3

--Repacker (level 3) - remove and reassign to Repacker (level 2) (not sure why there were two). 
--SELECT * FROM PRClassification where prcl_Name = 'Repacker' --310 level 2, 2120 level 3
--SELECT * FROM PRCompanyClassification WHERE prc2_ClassificationId = @REPACKER_3 --repacker level 3
UPDATE PRCompanyClassification SET prc2_ClassificationId = @REPACKER_2, prc2_UpdatedBy=-1, prc2_UpdatedDate=@RUN_DATE WHERE prc2_ClassificationId = @REPACKER_3
DELETE FROM PRClassification WHERE prcl_ClassificationId = @REPACKER_3

--Branch Sales Office (level 3) - remove and reassign  to Sales Office (level 2) 
--SELECT * FROM PRClassification where prcl_Name = 'Sales Office'  --380 - Sales Office Level 2
--SELECT * FROM PRClassification where prcl_Name = 'Branch Sales office' --2140 Branch Sales office level 3
--SELECT * FROM PRCompanyClassification WHERE prc2_ClassificationId = @BRANCH_SALES_OFFICE_3 
UPDATE PRCompanyClassification SET prc2_ClassificationId = @SALES_OFFICE_2, prc2_UpdatedBy=-1, prc2_UpdatedDate=@RUN_DATE WHERE prc2_ClassificationId = @BRANCH_SALES_OFFICE_3
DELETE FROM PRClassification WHERE prcl_ClassificationId = @BRANCH_SALES_OFFICE_3

--District Sales Office (level 3) - remove and reassign  to Sales Office (level 2) 
--SELECT * FROM PRClassification where prcl_Name = 'District Sales Office'
--SELECT * FROM PRCompanyClassification WHERE prc2_ClassificationId = @DISTRICT_SALES_OFFICE_3
UPDATE PRCompanyClassification SET prc2_ClassificationId = @SALES_OFFICE_2, prc2_UpdatedBy=-1, prc2_UpdatedDate=@RUN_DATE WHERE prc2_ClassificationId = @DISTRICT_SALES_OFFICE_3 
DELETE FROM PRClassification WHERE prcl_ClassificationId = @DISTRICT_SALES_OFFICE_3

--Division Sales Office (level 3) - remove and reassign  to Sales Office (level 2) 
--SELECT * FROM PRClassification where prcl_Name = 'dIVISION sALES OFFICE'  
--SELECT * FROM PRCompanyClassification WHERE prc2_ClassificationId = @DIVISION_SALES_OFFICE_3  
UPDATE PRCompanyClassification SET prc2_ClassificationId = @SALES_OFFICE_2, prc2_UpdatedBy=-1, prc2_UpdatedDate=@RUN_DATE WHERE prc2_ClassificationId = @DIVISION_SALES_OFFICE_3 
DELETE FROM PRClassification WHERE prcl_ClassificationId = @DIVISION_SALES_OFFICE_3 

--Regional Sales Office (level 3) - remove and reassign  to Sales Office (level 2) 
--SELECT * FROM PRClassification where prcl_Name = 'Regional Sales Office'  
--SELECT * FROM PRCompanyClassification WHERE prc2_ClassificationId = @REGIONAL_SALES_OFFICE_3  
UPDATE PRCompanyClassification SET prc2_ClassificationId = @SALES_OFFICE_2, prc2_UpdatedBy=-1, prc2_UpdatedDate=@RUN_DATE WHERE prc2_ClassificationId = @REGIONAL_SALES_OFFICE_3 
DELETE FROM PRClassification WHERE prcl_ClassificationId = @REGIONAL_SALES_OFFICE_3 

--Sales Office (level 3) - remove and reassign to Sales Office (level 2) (not sure why there were two). 
--SELECT * FROM PRCompanyClassification WHERE prc2_ClassificationId = @SALES_OFFICE_3
UPDATE PRCompanyClassification SET prc2_ClassificationId = @SALES_OFFICE_2, prc2_UpdatedBy=-1, prc2_UpdatedDate=@RUN_DATE WHERE prc2_ClassificationId = @SALES_OFFICE_3 
DELETE FROM PRClassification WHERE prcl_ClassificationId = @SALES_OFFICE_3 

--AFTER Comparison
--SELECT * FROM PRClassification WHERE prcl_Name = 'Procurement Office'

--SELECT COUNT(*) AfterCount_OldTable_ShouldBeZero FROM PRCompanyClassification WHERE prc2_ClassificationId IN (
--	@BUYING_OFFICE_3,
--	@BRANCH_BUYING_OFFICE_3,
--	@SEASONAL_BUYING_OFFICE_3,
--	@REPACKER_3,
--	@BRANCH_SALES_OFFICE_3,
--	@DIVISION_SALES_OFFICE_3 ,
--	@REGIONAL_SALES_OFFICE_3 ,
--	@SALES_OFFICE_3 
--)

--SELECT COUNT(*) FROM PRCompanyClassification WHERE prc2_UpdatedDate = @RUN_DATE
--SELECT * FROM PRCompanyClassification WHERE prc2_UpdatedDate = @RUN_DATE

UPDATE PRListing
  SET prlst_Listing = dbo.ufn_GetListingFromCompany(prlst_CompanyID, 0, 0),
		prlst_UpdatedDate = @RUN_DATE,
		prlst_UpdatedBy = 1
 WHERE prlst_CompanyID IN (SELECT PRC2_CompanyId FROM PRCompanyClassification WHERE prc2_UpdatedDate = @RUN_DATE)
GO

DELETE FROM CUSTOM_CAPTIONS WHERE Capt_FamilyType='Choices' and Capt_Family='IntlPhoneFormatFile' and Capt_Code='URL' 
INSERT INTO CUSTOM_CAPTIONS (Capt_CaptionId,Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_ES, Capt_Order, Capt_Component)
	VALUES ((select max(capt_captionid) + 1 from Custom_Captions), 'Choices', 'IntlPhoneFormatFile', 'URL', 'http://azqa.crm.bluebookservices.local/CRM/CustomPages/IntlPhoneFormats.xlsx', 'file://\\az-nc-fs-p1\vol1\Content Group\PROCEDURES-Listings\INTERNATIONAL Information\International Phone Formats.xlsx', '3', 'PRCo')

--Defect 4549 - prcommodity links
UPDATE PRCommodity SET prcm_PublicationArticleID = 10222 WHERE prcm_Name = 'Apple'
UPDATE PRCommodity SET prcm_PublicationArticleID = 10771 WHERE prcm_Name = 'Apricot'
UPDATE PRCommodity SET prcm_PublicationArticleID = 10782 WHERE prcm_Name = 'Artichoke'
UPDATE PRCommodity SET prcm_PublicationArticleID = 10803 WHERE prcm_Name = 'Asparagus'
UPDATE PRCommodity SET prcm_PublicationArticleID = 10828 WHERE prcm_Name = 'Avocado'
--UPDATE PRCommodity SET prcm_PublicationArticleID = 10844 WHERE prcm_Name = 'Baby Vegetable' --Not found
UPDATE PRCommodity SET prcm_PublicationArticleID = 10955 WHERE prcm_Name = 'Banana'

UPDATE PRCommodity SET prcm_PublicationArticleID = 10958 WHERE prcm_Name = 'Lima' --'Beans: Lima &amp; Snap'
UPDATE PRCommodity SET prcm_PublicationArticleID = 10958 WHERE prcm_Name_ES = 'Ejote (Snap Bean)' --'Beans: Lima &amp; Snap' 

UPDATE PRCommodity SET prcm_PublicationArticleID = 11153 WHERE prcm_Name = 'Beet'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11257 WHERE prcm_Name = 'Blackberry'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11264 WHERE prcm_Name = 'Blueberry'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11273 WHERE prcm_Name = 'Broccoli'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11464 WHERE prcm_Name = 'Brussels Sprouts' -- Not found
UPDATE PRCommodity SET prcm_PublicationArticleID = 11271 WHERE prcm_Name = 'Cabbage'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11453 WHERE prcm_Name = 'Cantaloupe'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11604 WHERE prcm_Name = 'Carambola'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11615 WHERE prcm_Name = 'Carrot'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11620 WHERE prcm_Name = 'Cauliflower'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11624 WHERE prcm_Name = 'Celery'
UPDATE PRCommodity SET prcm_PublicationArticleID = 6055 WHERE prcm_Name = 'Celery Root' 
UPDATE PRCommodity SET prcm_PublicationArticleID = 11643 WHERE prcm_Name = 'Cherry'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11871 WHERE prcm_Name = 'Chestnut'
--UPDATE PRCommodity SET prcm_PublicationArticleID = 11877 WHERE prcm_Name = 'Chile Peppers' --Not Found
UPDATE PRCommodity SET prcm_PublicationArticleID = 11885 WHERE prcm_Name = 'Cilantro'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11905 WHERE prcm_Name = 'Coconut'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12044 WHERE prcm_Name = 'Corn'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12138 WHERE prcm_Name = 'Cranberry'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12147 WHERE prcm_Name = 'Cucumber'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12158 WHERE prcm_Name = 'Date'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12164 WHERE prcm_Name = 'Dragon Fruit'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12170 WHERE prcm_Name = 'Eggplant'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12190 WHERE prcm_Name = 'Endive'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12198 WHERE prcm_Name = 'Fig'
--UPDATE PRCommodity SET prcm_PublicationArticleID = 12203 WHERE prcm_Name = 'French beans' --Could not find
--UPDATE PRCommodity SET prcm_PublicationArticleID = 12208 WHERE prcm_Name = 'Fresh Cut Produce' --could not find
UPDATE PRCommodity SET prcm_PublicationArticleID = 11918 WHERE prcm_Name = 'Garlic'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11930 WHERE prcm_Name = 'Ginger' 
UPDATE PRCommodity SET prcm_PublicationArticleID = 11934 WHERE prcm_Name = 'Grapefruit'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11946 WHERE prcm_Name = 'Grape'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11952 WHERE prcm_Name = 'Green Onion'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11960 WHERE prcm_Name = 'Greens'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11964 WHERE prcm_Name = 'Guava'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11970 WHERE prcm_Name = 'Herb'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11983 WHERE prcm_Name = 'Honeydew' --'Honeydew Melon'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11991 WHERE prcm_Name = 'Jicama'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12005 WHERE prcm_Name = 'Kiwifruit'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12010 WHERE prcm_Name = 'Lemon'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12015 WHERE prcm_Name = 'Lettuce'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12020 WHERE prcm_Name = 'Lime'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12027 WHERE prcm_Name = 'Mamey' --'Mamey Sapote'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12033 WHERE prcm_Name = 'Mandarin' --'Mandarins, Tangerines &amp; Clementines'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12033 WHERE prcm_Name = 'Tangerine' --'Mandarins, Tangerines &amp; Clementines'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12054 WHERE prcm_Name = 'Mango'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12057 WHERE prcm_Name = 'Mushroom'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12059 WHERE prcm_Name = 'Nectarine'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12061 WHERE prcm_Name = 'Okra'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12064 WHERE prcm_Name = 'Onion' --'Onions (dry)'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12066 WHERE prcm_Name = 'Orange'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12070 WHERE prcm_Name = 'Papaya'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12074 WHERE prcm_Name = 'Parsley'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12078 WHERE prcm_Name = 'Peach'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12080 WHERE prcm_Name = 'Pear'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12082 WHERE prcm_Name = 'Pea'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12086 WHERE prcm_Name = 'Pepper'
--UPDATE PRCommodity SET prcm_PublicationArticleID = 12090 WHERE prcm_Name = 'Peppers (greenhouse)' --could not find
UPDATE PRCommodity SET prcm_PublicationArticleID = 12095 WHERE prcm_Name = 'Pineapple'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12171 WHERE prcm_Name = 'Plantain'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12178 WHERE prcm_Name = 'Plum'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12183 WHERE prcm_Name = 'Pluot'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12187 WHERE prcm_Name = 'Pomegranate'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12189 WHERE prcm_Name = 'Potato'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12192 WHERE prcm_Name = 'Pumpkin'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12210 WHERE prcm_Name = 'Radish'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12215 WHERE prcm_Name = 'Rambutan'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12219 WHERE prcm_Name = 'Raspberry'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12212 WHERE prcm_Name = 'Rhubarb'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12223 WHERE prcm_Name = 'Romaine' --'Romaine lettuce'
UPDATE PRCommodity SET prcm_PublicationArticleID = 12231 WHERE prcm_Name = 'Snow' --'Snow Peas'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11821 WHERE prcm_Name = 'Spinach'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11789 WHERE prcm_Name = 'Squash'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11780 WHERE prcm_Name = 'Strawberry'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11742 WHERE prcm_Name = 'Sweet Potato'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11752 WHERE prcm_Name = 'Tomato'
--UPDATE PRCommodity SET prcm_PublicationArticleID = 11729 WHERE prcm_Name = 'Tomatoes (greenhouse)' --could not find
--UPDATE PRCommodity SET prcm_PublicationArticleID = 11719 WHERE prcm_Name = 'Tree Nuts' --could not find
UPDATE PRCommodity SET prcm_PublicationArticleID = 11704 WHERE prcm_Name = 'Turmeric'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11670 WHERE prcm_Name = 'Turnip'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11661 WHERE prcm_Name = 'Watermelon'
UPDATE PRCommodity SET prcm_PublicationArticleID = 11632 WHERE prcm_Name = 'Zucchini'

--Defect 4349 (part 2)
UPDATE PRClassification SET prcl_Description='Location focused on buying product.  Purchases are generally delivered to points other than Buying Office.', prcl_Description_ES='Ubicación enfocada en comprar producto. Las compras generalmente se envían a puntos distintos a la Oficina de Compras.' WHERE prcl_name = 'Procurement Office'
Go


--Defect 4581 - Flower/Flowers and Pepper/Peppermint
DECLARE @Start datetime = GETDATE()

ALTER TABLE CRM.dbo.PRCompanyCommodityAttribute DISABLE TRIGGER ALL

UPDATE PRCompanyCommodityAttribute SET prcca_UpdatedDate=@Start, prcca_UpdatedBy = -1, 
	prcca_PublishedDisplay = 
		CASE WHEN prat_Abbreviation IS NULL 
		THEN 
			'Flowers' 
		ELSE 
			CASE WHEN prat_PlacementAfter = 'Y'
			THEN
						'Flowers' + LOWER(prat_Abbreviation)
			ELSE
					prat_Abbreviation + 'flowers'
			END
		END
FROM
	PRCompanyCommodityAttribute 
	LEFT OUTER JOIN PRAttribute ON prat_attributeid = prcca_AttributeId
WHERE prcca_CommodityId = 14

UPDATE PRCompanyCommodityAttribute SET prcca_UpdatedDate=@Start, prcca_UpdatedBy = -1, 
	prcca_PublishedDisplay = 
		CASE WHEN prat_Abbreviation IS NULL 
		THEN 
			'Peppermint' 
		ELSE 
			CASE WHEN prat_PlacementAfter = 'Y'
			THEN
						'Peppermint' + LOWER(prat_Abbreviation)
			ELSE
					prat_Abbreviation + 'peppermint'
			END
		END
FROM
	PRCompanyCommodityAttribute 
	LEFT OUTER JOIN PRAttribute ON prat_attributeid = prcca_AttributeId
WHERE prcca_CommodityId = 262

UPDATE PRCompanyCommodityAttribute SET prcca_UpdatedDate=@Start, prcca_UpdatedBy = -1, 
	prcca_PublishedDisplay = 
		CASE WHEN prcca_GrowingMethodId = 25 THEN 'Org' + 'gourds'
		WHEN prat_Abbreviation IS NULL THEN 'Gourds' 
		ELSE 
			CASE WHEN prat_PlacementAfter = 'Y'
			THEN
						'Gourds' + LOWER(prat_Abbreviation)
			ELSE
					prat_Abbreviation + 'gourds'
			END
		END
FROM
	PRCompanyCommodityAttribute 
	LEFT OUTER JOIN PRAttribute ON prat_attributeid = prcca_AttributeId
WHERE prcca_CommodityId = 338

UPDATE PRCompanyCommodityAttribute SET prcca_UpdatedDate=@Start, prcca_UpdatedBy = -1, 
	prcca_PublishedDisplay = 'Man' 
WHERE
	prcca_CommodityId = 98
	AND prcca_AttributeId IS NULL 
	AND prcca_PublishedDisplay IS NULL
		AND prcca_PublishWithGM IS NULL
		AND prcca_GrowingMethodId IS NULL

ALTER TABLE CRM.dbo.PRCompanyCommodityAttribute ENABLE TRIGGER ALL
GO

DECLARE @AdEligiblePageID int = 6048
DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = @AdEligiblePageID
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (@AdEligiblePageID,'PMSHPSQ','Produce Marketing Site','ProduceMarketingSite',1,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

SET @AdEligiblePageID = 6049
DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = @AdEligiblePageID
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (@AdEligiblePageID,'PMSHPB','Produce Marketing Site','ProduceMarketingSite',1,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

EXEC usp_UpdateSQLIdentity 'PRAdEligiblePage', 'pradep_AdEligiblePageID'
Go

--DEFECT 4584
IF EXISTS  (SELECT * FROM dbo.sysobjects  WHERE id = object_id(N'[dbo].[ufn_WPTemp]') AND xtype in (N'FN', N'IF', N'TF')) 
	DROP FUNCTION [dbo].[ufn_WPTemp]
GO

CREATE FUNCTION [dbo].[ufn_WPTemp] ( 
    @PublicationArticleID int
)
RETURNS varchar(2000)
AS
BEGIN
    -- Build a comma-delimited list
    DECLARE @List varchar(2000)
    SELECT @List =  COALESCE(@List + ', ', '') + CAST(prpbarc_CompanyID as varchar(8))
      FROM PRPublicationArticleCompany
     WHERE prpbarc_PublicationArticleID = @PublicationArticleID
    ORDER BY prpbarc_CompanyID;

    RETURN @List;
END
GO

--Reset associated-companies data for POSTS in scope
DELETE FROM WordPress.dbo.wp_postmeta WHERE meta_key = 'associated-companies' AND post_id in 
(
	SELECT CAST(ID as int) AS prpbar_PublicationArticleID 
	FROM WordPress.dbo.wp_posts WITH (NOLOCK)
	    LEFT OUTER JOIN WordPress.dbo.wp_PostMeta WITH (NOLOCK) ON wp_Posts.ID = wp_postmeta.post_id AND meta_key = 'associated-companies'
	WHERE post_type = 'post'
		   AND post_status in('publish')
		   AND id NOT IN (SELECT post_ID FROM WordPress.dbo.wp_postmeta WHERE meta_key = 'blueprintEdition')
)

INSERT INTO WordPress.dbo.wp_postmeta (post_id, meta_key, meta_value)
SELECT ID, 'associated-companies', CRM.dbo.ufn_WPTemp(ID)
  FROM WordPress.dbo.wp_posts
	WHERE post_type = 'post'
        AND post_status in('publish')
        AND id NOT IN (SELECT post_ID FROM WordPress.dbo.wp_postmeta WHERE meta_key = 'blueprintEdition')
        AND CRM.dbo.ufn_WPTemp(ID) IS NOT NULL
ORDER BY ID

IF EXISTS  (SELECT * FROM dbo.sysobjects  WHERE id = object_id(N'[dbo].[ufn_WPTemp]') AND xtype in (N'FN', N'IF', N'TF')) 
	DROP FUNCTION [dbo].[ufn_WPTemp]
GO

--DEFECT 4514 prss_recordofactivity / ckeditor updates - replace CRLF with <p> tags - 11590 rows
UPDATE PRSSFile SET prss_recordofactivity = '<p>' + REPLACE(prss_recordofactivity, CHAR(13)+CHAR(10), '</p><p>') + '</p>' where prss_recordofactivity is not null


--Spanish version of URL for passwordchange.aspx
UPDATE Custom_Captions SET Capt_ES=Capt_US WHERE Capt_FamilyType='Choices' AND Capt_Family='BBOS' AND Capt_Code='URL'

--Defect 4504
UPDATE PRClassification SET prcl_Description_ES=NULL WHERE prcl_Name='Leasing' and prcl_Abbreviation='Leasing'
GO

--DEFECT 4425
declare @capt_NextId int
DELETE FROM CUSTOM_CAPTIONS WHERE Capt_FamilyType='Choices' AND Capt_Family='EmailTemplate' AND Capt_Code LIKE 'YouHaveMsg_%'
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'EmailTemplate', 'YouHaveMsg_L', '<p style="font-size:9pt;">You have ', 
		'<p style="font-size:9pt;">Tiene ', -1, getdate(), -1, getdate())
exec usp_getNextId 'custom_captions', @capt_NextId output
INSERT INTO CUSTOM_CAPTIONS (capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_ES, capt_createdby, capt_createddate, capt_updatedby, capt_updateddate) 
	VALUES (@capt_NextId, 'Choices', 'EmailTemplate', 'YouHaveMsg_R', ' Business Reports to use this year.  Login now to get yours today!</p><p style="font-size:9pt;">Need more reports? Contact a customer service rep.</p>', 
		' informes de negocios para usar este año. ¡Inicie sesión ahora para obtener el suyo hoy!</p><p style="font-size:9pt;">¿Necesita más informes? Llame y hable con un representante de servicio al cliente.</p>', -1, getdate(), -1, getdate())
GO

--DEFECT 4549 -- Commodity article updates per Kathi
UPDATE PRCommodity SET prcm_PublicationArticleID=12086 WHERE prcm_CommodityId = 521 --Bell Pepper  ArticleID=12086 
UPDATE PRCommodity SET prcm_PublicationArticleID=12033 WHERE prcm_CommodityId = 558 --Clementine Mandarin  ArticleID=12033   commodity=558
UPDATE PRCommodity SET prcm_PublicationArticleID=NULL WHERE prcm_CommodityId = 412 --Pinto Bean -- should be no link 
UPDATE PRCommodity SET prcm_PublicationArticleID=12066 WHERE prcm_CommodityId = 75 --Naval Orange  ArticleID=12066 
UPDATE PRCommodity SET prcm_PublicationArticleID=12086 WHERE prcm_CommodityId = 523 --Yellow Bell Pepper  ArticleID=12086 
UPDATE PRCommodity SET prcm_PublicationArticleID=11624 WHERE prcm_CommodityId = 440 --Celery Root  ArticleID=11624 
UPDATE PRCommodity SET prcm_PublicationArticleID=12015 WHERE prcm_CommodityId = 388 --Leaf Lettuce  ArticleID=12015 
UPDATE PRCommodity SET prcm_PublicationArticleID=12015 WHERE prcm_CommodityId = 390 --Red Lettuce  ArticleID=12015 
UPDATE PRCommodity SET prcm_PublicationArticleID=12066 WHERE prcm_CommodityId = 77 --Minneola Orange  ArticleID=12066 
UPDATE PRCommodity SET prcm_PublicationArticleID=12015 WHERE prcm_CommodityId = 392 --Butter Lettuce  ArticleID=12015 
UPDATE PRCommodity SET prcm_PublicationArticleID=11752 WHERE prcm_CommodityId = 540 --Grape Tomatoes pointing to Grapes. Should be tomatoes ArticleID=11752 
UPDATE PRCommodity SET prcm_PublicationArticleID=12086 WHERE prcm_CommodityId = 527 --Orange Bell Peppers goes to Oranges. Should be Peppers ArticleID=12086 
UPDATE PRCommodity SET prcm_PublicationArticleID=11752 WHERE prcm_CommodityId = 539 --Plum Tomatoes goes to Plums. Should be tomatoes ArticleID=11752 
UPDATE PRCommodity SET prcm_PublicationArticleID=11789 WHERE prcm_CommodityId = 329 --Banana Hardshell squash is pointing to Banana. Should be squash ArticleID=11789 
UPDATE PRCommodity SET prcm_PublicationArticleID=12080 WHERE prcm_CommodityId = 165 --should be ArticleID=12080 for the Asian pear 

--New Commodity articles and PDFs
UPDATE PRCommodity SET prcm_KYCPostTitle = 'Rutabagas', prcm_PublicationArticleID=15828 WHERE prcm_Name like '%rutabaga%'
UPDATE PRCommodity SET prcm_KYCPostTitle = 'Endive', prcm_PublicationArticleID=15824 WHERE prcm_Name like '%endiv%'
UPDATE PRCommodity SET prcm_KYCPostTitle = 'Horseradish Root', prcm_PublicationArticleID=15825 WHERE prcm_CommodityCode = 'Hrroot' --prcm_Name like '%Horseradish%'
UPDATE PRCommodity SET prcm_KYCPostTitle = 'Jackfruit',prcm_PublicationArticleID= 15826 WHERE prcm_Name like '%Jack fruit%'
UPDATE PRCommodity SET prcm_KYCPostTitle = 'Leeks',prcm_PublicationArticleID= 15827 WHERE prcm_Name like '%Leek%'