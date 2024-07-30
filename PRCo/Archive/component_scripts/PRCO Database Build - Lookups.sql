SET NOCOUNT ON
GO
DECLARE @CustomContent varchar(8000)
-- Create a table named "tAccpacComponent" that has a single column and value, the Accpac 
-- Component name value.  All create methods will look to this table first to determine 
-- if a vlue is set.  If it finds it, this value will be used; if not, the entity name is
-- used as the component name value
-- This allows us to "block" together components as we set up the custom tables and fields.

-- create the physical table 
-- search for PRCompanyClassification to see how this is used   
DECLARE @DEFAULT_COMPONENT_NAME nvarchar(20)
SET @DEFAULT_COMPONENT_NAME = 'PRGeneral'

IF not exists (select 1 from sysobjects where id = object_id('tAccpacComponentName') 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
  CREATE TABLE dbo.tAccpacComponentName ( ComponentName nvarchar(20) NULL )
  -- Create a default row so that all we have to do are updates
  Insert into tAccpacComponentName Values (@DEFAULT_COMPONENT_NAME)
END

-- ****************************************************************************
-- *******************  PRLookups  ********************************************
-- Set up the Lookup Tables and fields into their own Component called PRLookups
UPDATE tAccpacComponentName SET ComponentName = 'PRLookups'

-- ATTRIBUTE START
exec usp_AccpacCreateTable 'PRAttribute', 'prat', 'prat_AttributeId'
exec usp_AccpacCreateKeyField 'PRAttribute', 'prat_AttributeId', 'Attribute Id' 

exec usp_AccpacCreateTextField     'PRAttribute', 'prat_Name', 'Attribute', 100
exec usp_AccpacCreateSelectField   'PRAttribute', 'prat_Type', 'Type', 'prat_Type' 
exec usp_AccpacCreateCheckboxField 'PRAttribute', 'prat_IPDFlag', 'IPD Flag'
exec usp_AccpacCreateTextField     'PRAttribute', 'prat_Abbreviation', 'Abbreviation', 100
exec usp_AccpacCreateCheckboxField 'PRAttribute', 'prat_PlacementAfter', 'Placement After Flag'

-- BUSINESS EVENT TYPE
exec usp_AccpacCreateTable 'PRBusinessEventType', 'prbt', 'prbt_BusinessEventTypeId'
exec usp_AccpacCreateKeyField 'PRBusinessEventType', 'prbt_BusinessEventTypeId', 'Business Event Type Id' 

exec usp_AccpacCreateTextField 'PRBusinessEventType', 'prbt_Name', 'Name', 100
exec usp_AccpacCreateNumericField 'PRBusinessEventType', 'prbt_PublishDefaultTime', 'Publish Default Time', 10

-- CITY START
exec usp_AccpacCreateTable 'PRCity', 'prci', 'prci_CityId'
exec usp_AccpacCreateKeyField 'PRCity', 'prci_CityId', 'City', 40 
exec usp_AccpacCreateTextField 'PRCity', 'prci_City', 'City', 34
exec usp_AccpacCreateTextField 'PRCity', 'prci_County', 'County', 25
exec usp_AccpacCreateSearchSelectField 'PRCity', 'prci_StateId', 'State', 'PRState'
exec usp_AccpacCreateTextField 'PRCity', 'prci_RatingTerritory', 'Rating Territory', 30
exec usp_AccpacCreateUserSelectField 'PRCity', 'prci_RatingUserId', 'Assigned Rating Analyst'
exec usp_AccpacCreateTextField 'PRCity', 'prci_SalesTerritory', 'Sales Territory', 30
exec usp_AccpacCreateUserSelectField 'PRCity', 'prci_InsideSalesRepId', 'Inside Sales Rep'
exec usp_AccpacCreateUserSelectField 'PRCity', 'prci_FieldSalesRepId', 'Field Sales Rep'
exec usp_AccpacCreateUserSelectField 'PRCity', 'prci_ListingSpecialistId', 'Listing Specialist Rep'
exec usp_AccpacCreateUserSelectField 'PRCity', 'prci_CustomerServiceId', 'Customer Service Rep'

-- CREDIT WORTH RATING START
exec usp_AccpacCreateTable 'PRCreditWorthRating', 'prcw', 'prcw_CreditWorthRatingId'
exec usp_AccpacCreateKeyField 'PRCreditWorthRating', 'prcw_CreditWorthRatingId', 'Credit Worth Rating Id' 

exec usp_AccpacCreateTextField 'PRCreditWorthRating', 'prcw_Name', 'Credit Worth Rating', 10
exec usp_AccpacCreateTextField 'PRCreditWorthRating', 'prcw_EnglishDescription', 'Description', 90
exec usp_AccpacCreateTextField 'PRCreditWorthRating', 'prcw_SpanishDescription', 'Description', 105
exec usp_AccpacCreateIntegerField 'PRCreditWorthRating', 'prcw_Order', 'Order', 10

-- INTEGRITY RATING
exec usp_AccpacCreateTable 'PRIntegrityRating', 'prin', 'prin_IntegrityRatingId'
exec usp_AccpacCreateKeyField 'PRIntegrityRating', 'prin_IntegrityRatingId', 'Integrity Rating Id' 

exec usp_AccpacCreateTextField 'PRIntegrityRating', 'prin_Name', 'Integrity Rating', 6
exec usp_AccpacCreateTextField 'PRIntegrityRating', 'prin_TradeReportDescription', 'Integrity', 4
exec usp_AccpacCreateTextField 'PRIntegrityRating', 'prin_EnglishDescription', 'Description', 50
exec usp_AccpacCreateTextField 'PRIntegrityRating', 'prin_SpanishDescription', 'Spanish Description', 50
exec usp_AccpacCreateIntegerField 'PRIntegrityRating', 'prin_Order', 'Order', 10
exec usp_AccpacCreateIntegerField 'PRIntegrityRating', 'prin_Weight', 'Weight', 10

-- PAY RATING
exec usp_AccpacCreateTable 'PRPayRating', 'prpy', 'prpy_PayRatingId'
exec usp_AccpacCreateKeyField 'PRPayRating', 'prpy_PayRatingId', 'Pay Rating Id' 

exec usp_AccpacCreateTextField 'PRPayRating', 'prpy_Name', 'Pay Rating', 6
exec usp_AccpacCreateTextField 'PRPayRating', 'prpy_TradeReportDescription', 'Pay Rating', 15
exec usp_AccpacCreateTextField 'PRPayRating', 'prpy_EnglishDescription', 'Description', 70
exec usp_AccpacCreateTextField 'PRPayRating', 'prpy_SpanishDescription', 'Spanish Description', 70
exec usp_AccpacCreateIntegerField 'PRPayRating', 'prpy_Order', 'Order', 10
exec usp_AccpacCreateIntegerField 'PRPayRating', 'prpy_Weight', 'Weight', 10

-- RATING NUMERAL
exec usp_AccpacCreateTable 'PRRatingNumeral', 'prrn', 'prrn_RatingNumeralId'
exec usp_AccpacCreateKeyField 'PRRatingNumeral', 'prrn_RatingNumeralId', 'Rating Numeral Id' 

exec usp_AccpacCreateTextField 'PRRatingNumeral', 'prrn_Name', 'Rating Numeral', 10
exec usp_AccpacCreateSelectField 'PRRatingNumeral', 'prrn_Type', 'Type', 'prrn_Type' 
exec usp_AccpacCreateCheckboxField 'PRRatingNumeral', 'prrn_Interim', 'Interim'
exec usp_AccpacCreateTextField 'PRRatingNumeral', 'prrn_EnglishDescription', 'Description', 105
exec usp_AccpacCreateTextField 'PRRatingNumeral', 'prrn_SpanishDescription', 'Spanish Description', 105
exec usp_AccpacCreateIntegerField 'PRRatingNumeral', 'prrn_Order', 'Order', 10
exec usp_AccpacCreateCheckboxField 'PRRatingNumeral', 'prrn_SuppressWorthRating', 'Suppress Worth Rating'
exec usp_AccpacCreateCheckboxField 'PRRatingNumeral', 'prrn_SuppressIntegrityRating', 'Suppress Integrity Rating'
exec usp_AccpacCreateCheckboxField 'PRRatingNumeral', 'prrn_SuppressPayRating', 'Suppress Pay Rating'
exec usp_AccpacCreateCheckboxField 'PRRatingNumeral', 'prrn_SuppressNumerals', 'SuppressNumerals'
exec usp_AccpacCreateCheckboxField 'PRRatingNumeral', 'prrn_AutoRemove', 'Auto Remove'
exec usp_AccpacCreateCheckboxField 'PRRatingNumeral', 'prrn_AutoHold', 'Auto Hold'

-- PERSON EVENT TYPE
exec usp_AccpacCreateTable 'PRPersonEventType', 'prpt', 'prpt_PersonEventTypeId'
exec usp_AccpacCreateKeyField 'PRPersonEventType', 'prpt_PersonEventTypeId', 'Person Event Type Id' 

exec usp_AccpacCreateTextField 'PRPersonEventType', 'prpt_Name', 'Name', 100
exec usp_AccpacCreateNumericField 'PRPersonEventType', 'prpt_PublishDefaultTime', 'Publish Default Time', 10

-- RELATIONSHIP TYPE
exec usp_AccpacCreateTable 'PRRelationshipType', 'prrt', 'prrt_RelationshipTypeId'
exec usp_AccpacCreateKeyField 'PRRelationshipType', 'prrt_RelationshipTypeId', 'Relationship Type Id' 
exec usp_AccpacCreateTextField 'PRRelationshipType', 'prrt_Name', 'Rel. Number', 2
exec usp_AccpacCreateTextField 'PRRelationshipType', 'prrt_Description', 'Description', 100
exec usp_AccpacCreateSelectField 'PRRelationshipType', 'prrt_Category', 'Category', 'prrt_Category'

-- ROLE 
exec usp_AccpacCreateTable 'PRRole', 'prro', 'prro_RoleId'
exec usp_AccpacCreateKeyField 'PRRole', 'prro_RoleId', 'Role Id' 
exec usp_AccpacCreateTextField 'PRRole', 'prro_Name', 'Role', 20
exec usp_AccpacCreateSelectField 'PRRole', 'prro_Category', 'Category', 'prro_Category'
exec usp_AccpacCreateCheckboxField 'PRRole', 'prro_Multiplicity', 'Multiple Allowed'

-- STATE
exec usp_AccpacCreateTable 'PRState', 'prst', 'prst_StateId'
exec usp_AccpacCreateKeyField 'PRState', 'prst_StateId', 'State Name' 
exec usp_AccpacCreateTextField 'PRState', 'prst_State', 'State Name', 30
exec usp_AccpacCreateIntegerField 'PRState', 'prst_CountryId', 'Country', 20
exec usp_AccpacCreateTextField 'PRState', 'prst_Abbreviation', 'State', 10

-- COUNTRY -- RSH added 10/12/05
exec usp_AccpacCreateTable 'PRCountry', 'prcn', 'prcn_CountryId'
exec usp_AccpacCreateKeyField 'PRCountry', 'prcn_CountryId', 'Country' 
exec usp_AccpacCreateTextField 'PRCountry', 'prcn_Country', 'Country', 30
exec usp_AccpacCreateTextField 'PRCountry', 'prcn_CountryCode', 'Country Code', 3
exec usp_AccpacCreateTextField 'PRCountry', 'prcn_Language', 'Language', 1
exec usp_AccpacCreateTextField 'PRCountry', 'prcn_IATACode', 'IATA Code', 2

-- STOCK EXCHANGE
exec usp_AccpacCreateTable 'PRStockExchange', 'prex', 'prex_StockExchangeId'
exec usp_AccpacCreateKeyField 'PRStockExchange', 'prex_StockExchangeId', 'Stock Exchange Id' 

exec usp_AccpacCreateTextField 'PRStockExchange', 'prex_Name', 'Stock Exchange', 10
exec usp_AccpacCreateCheckboxField 'PRStockExchange', 'prex_Publish', 'Publish'
exec usp_AccpacCreateIntegerField 'PRStockExchange', 'prex_Order', 'Order', 10

-- TERMINAL MARKET
exec usp_AccpacCreateTable 'PRTerminalMarket', 'prtm', 'prtm_TerminalMarketId'
exec usp_AccpacCreateKeyField 'PRTerminalMarket', 'prtm_TerminalMarketId', 'Terminal Market Id' 

exec usp_AccpacCreateTextField 'PRTerminalMarket', 'prtm_FullMarketName', 'Full Market Name', 100
exec usp_AccpacCreateTextField 'PRTerminalMarket', 'prtm_ListedMarketName', 'Listed Market Name', 100
exec usp_AccpacCreateTextField 'PRTerminalMarket', 'prtm_Address', 'Address', 100
exec usp_AccpacCreateTextField 'PRTerminalMarket', 'prtm_City', 'City', 34
exec usp_AccpacCreateTextField 'PRTerminalMarket', 'prtm_State', 'State', 30
exec usp_AccpacCreateTextField 'PRTerminalMarket', 'prtm_Zip', 'Zip', 10

-- DL PHRASE
exec usp_AccpacCreateTable 'PRDLPhrase', 'prdlp', 'prdlp_DLPhraseId'
exec usp_AccpacCreateKeyField 'PRDLPhrase', 'prdlp_DLPhraseId', 'DL Phrase Id' 

exec usp_AccpacCreateTextField 'PRDLPhrase', 'prdlp_Phrase', 'DL Phrase', 100
exec usp_AccpacCreateIntegerField 'PRDLPhrase', 'prdlp_Order', 'Order', 4

-- CREDIT SHEET PHRASE
exec usp_AccpacCreateTable 'PRCSPhrase', 'prcsp', 'prcsp_CSPhraseId'
exec usp_AccpacCreateKeyField 'PRCSPhrase', 'prcsp_CSPhraseId', 'CS Phrase Id' 
exec usp_AccpacCreateTextField 'PRCSPhrase', 'prcsp_Phrase', 'CS Phrase', 100
exec usp_AccpacCreateIntegerField 'PRCSPhrase', 'prcsp_Order', 'Order', 4

-- *******************  END PRLookups  ****************************************
-- ****************************************************************************



DROP TABLE tAccpacComponentName 

GO

SET NOCOUNT OFF
GO
