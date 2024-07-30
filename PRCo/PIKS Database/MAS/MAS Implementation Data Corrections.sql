USE MAS_SYSTEM

DELETE FROM MAS_SYSTEM.dbo.SY_Country;  
INSERT INTO MAS_SYSTEM.dbo.SY_Country
SELECT CASE 
          WHEN LEN(CAST(prcn_CountryId AS VARCHAR)) = 1 THEN '00' + CAST(prcn_CountryId AS VARCHAR)
          WHEN LEN(CAST(prcn_CountryId AS VARCHAR)) = 2 THEN '0' + CAST(prcn_CountryId AS VARCHAR)
          ELSE CAST(prcn_CountryId AS VARCHAR)
       END, 
       prcn_Country, ISNULL(prcn_CountryCode, '')
  FROM CRM.dbo.PRCountry
 WHERE prcn_CountryId >=0;

 
   

ALTER TABLE MAS_SYSTEM.[dbo].[SY_ZipCode]
 DROP CONSTRAINT KPRIMARY_SY_ZipCode
 GO

ALTER TABLE MAS_SYSTEM.[dbo].[SY_ZipCode] ALTER COLUMN CountryCode varchar(3) not null
GO

ALTER TABLE  MAS_SYSTEM.[dbo].[SY_ZipCode] ADD  CONSTRAINT [KPRIMARY_SY_ZipCode] PRIMARY KEY CLUSTERED 
(
	[ZipCode] ASC,
	CountryCode
)
GO



UPDATE MAS_SYSTEM.dbo.SY_ZipCode
   SET CountryCode = '001'
 WHERE CountryCode = 'USA';
 
UPDATE MAS_SYSTEM.dbo.SY_ZipCode
   SET CountryCode = '002'
 WHERE CountryCode = 'CAN'; 
 
UPDATE MAS_SYSTEM.dbo.SY_ZipCode
   SET CountryCode = '003'
 WHERE CountryCode = 'MEX';  
 
UPDATE MAS_SYSTEM.dbo.SY_ZipCode
   SET CountryCode = '008'
 WHERE CountryCode = 'AUS';   
 
DELETE FROM MAS_SYSTEM.dbo.SY_ZipCode
WHERE CountryCode NOT IN ('001', '002', '003', '008');

INSERT INTO MAS_SYSTEM.dbo.SY_ZipCode
SELECT DISTINCT PostCode, '', CASE WHEN prcn_CountryID IN ('001', '002') THEN State ELSE '' END As StateID, prcn_CountryID
  FROM CRM.dbo.vPRCompanyAccounting
       LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_ZipCode ON PostCode = ZipCode AND prcn_CountryID = CountryCode
 WHERE PostCode IS NOT NULL
   AND PostCode <> ''
   AND prcn_CountryID IS NOT NULL
   AND prcn_CountryID NOT IN ('0-1')
   AND ZipCode IS NULL
   AND comp_CompanyID NOT IN (255333, 255906, 257561, 257408, 179068, 255713, 257458, 257621, 187917, 183899, 168380)
Go


--DELETE FROM SY_SalesTaxCodeDetail;
--DELETE FROM SY_SalesTaxCode;
--DELETE from SY_SalesTaxScheduleDetail;
--DELETE from SY_SalesTaxSchedule;
Go

USE MAS_PRC
UPDATE AR_InvoiceHistoryHeader
   SET UDF_MASTER_INVOICE = UDF_MAST_INV
 WHERE UDF_MAST_INV <> ''
   AND (UDF_MASTER_INVOICE IS NULL OR UDF_MASTER_INVOICE = '');
Go   

