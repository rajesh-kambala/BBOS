--8.12 Release
USE CRM

--Defect 7009 Add a record to allow companysearchbyhasnotes
UPDATE PRBBOSPrivilege SET AccessLevel=350 WHERE 
	Privilege='CompanySearchByHasNotes' AND IndustryType='L'

--Defect 7027 - Ecuador
DELETE FROM PRAttribute WHERE prat_AttributeId = 1004
INSERT INTO PRAttribute (prat_AttributeId, prat_Name, prat_Type, prat_Abbreviation, prat_PlacementAfter, prat_Name_ES, prat_CreatedBy, prat_CreatedDate, prat_UpdatedBy, prat_UpdatedDate, prat_Timestamp)
VALUES (1004, 'Ecuador', 'CO', 'Ecuadorian', NULL, 'Ecuador', 3, GETDATE(), 3, GETDATE(), GETDATE());

exec usp_PopulatePRCommodity2
exec usp_PopulatePRCommodityTranslation

--Defect 7025 - Express Update NewProduct changes
UPDATE NewProduct SET
	prod_PRDescription='Express Updates reflect important changes that have occurred to all Blue Book Listings and is delivered daily by email. Updates include changes in the following categories: Ownership, licensing, rating, personnel, contact information.',
	prod_PRDescription_es='Los Informes de Actualizaciones Express reflejan cambios importantes que se han producido a Listados del Libro Azul y son enviados diariamente por correo electrónico. Las actualizaciones incluyen cambios en las siguientes categorías: Propiedad, licenciamiento, calificación, de personal e información de contacto.' 
WHERE prod_productid=21 --Express Update Service
