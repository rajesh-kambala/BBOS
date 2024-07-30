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
SET @DEFAULT_COMPONENT_NAME = 'PRRating'

IF not exists (select 1 from sysobjects where id = object_id('tAccpacComponentName') 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
  CREATE TABLE dbo.tAccpacComponentName ( ComponentName nvarchar(20) NULL )
  -- Create a default row so that all we have to do are updates
  Insert into tAccpacComponentName Values (@DEFAULT_COMPONENT_NAME)
END


-- RATING
exec usp_AccpacCreateTable 'PRRating', 'prra', 'prra_RatingId'
exec usp_AccpacCreateKeyField 'PRRating', 'prra_RatingId', 'Rating Id' 

exec usp_AccpacCreateSearchSelectField 'PRRating', 'prra_CompanyId', 'Company', 'Company', 10, '17', NULL, 'Y'
exec usp_AccpacCreateDateField 'PRRating', 'prra_Date', 'Effective Date'
exec usp_AccpacCreateCheckboxField 'PRRating', 'prra_Current', 'Current'
-- these lookups cannot be AdvSearchSelect because there is no way to order them appropriately
exec usp_AccpacCreateIntegerField 'PRRating', 'prra_CreditWorthId', 'Credit Worth'
exec usp_AccpacCreateIntegerField 'PRRating', 'prra_IntegrityId', 'Integrity'
exec usp_AccpacCreateIntegerField 'PRRating', 'prra_PayRatingId', 'Pay Rating'

exec usp_AccpacCreateMultilineField 'PRRating', 'prra_InternalAnalysis', 'Internal Analysis', 75, '5'
exec usp_AccpacCreateMultilineField 'PRRating', 'prra_PublishedAnalysis', 'Published Analysis', 75, '5'
-- This may need to be an advanced search select
exec usp_AccpacCreateIntegerField 'PRRating', 'prra_CommunicationId', 'Communication'

-- RATING NUMERAL ASSIGNED 
exec usp_AccpacCreateTable 'PRRatingNumeralAssigned', 'pran', 'pran_RatingNumeralAssignedId'
exec usp_AccpacCreateKeyField 'PRRatingNumeralAssigned', 'pran_RatingNumeralAssignedId', 'Assigned Rating Numeral Id' 

exec usp_AccpacCreateSearchSelectField 'PRRatingNumeralAssigned', 'pran_RatingId', 'Rating', 'PRRating', 10, 0, NULL, 'Y'
exec usp_AccpacCreateSearchSelectField 'PRRatingNumeralAssigned', 'pran_RatingNumeralId', 'Rating Numeral', 'PRRatingNumeral', 10, 0, NULL, 'Y'

DROP TABLE tAccpacComponentName 

GO

SET NOCOUNT OFF
GO
