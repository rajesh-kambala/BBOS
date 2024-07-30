EXEC usp_AccpacCreateCheckboxField  'PRCompanyInfoProfile', 'prc5_ReceiveChristmasCard', 'Receives BBSI Christmas Card'
EXEC usp_AccpacCreateUserSelectField 'PRCompanyInfoProfile', 'prc5_ChristmasCardAssociate1', 'Associate 1'
EXEC usp_AccpacCreateUserSelectField 'PRCompanyInfoProfile', 'prc5_ChristmasCardAssociate2', 'Associate 2'
EXEC usp_AccpacCreateUserSelectField 'PRCompanyInfoProfile', 'prc5_ChristmasCardAssociate3', 'Associate 3'
EXEC usp_AccpacCreateUserSelectField 'PRCompanyInfoProfile', 'prc5_ChristmasCardFieldRep', 'Field Rep'
Go


EXEC usp_DeleteCustom_ScreenObject 'PRCompanyChristmasCards'
EXEC usp_AddCustom_ScreenObjects 'PRCompanyChristmasCards', 'Screen', 'PRCompanyInfoProfile', 'N', 0, 'PRCompanyInfoProfile'
EXEC usp_AddCustom_Screens 'PRCompanyChristmasCards', 10, 'prc5_ReceiveChristmasCard', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyChristmasCards', 20, 'prc5_ChristmasCardAssociate1', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyChristmasCards', 30, 'prc5_ChristmasCardAssociate2', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyChristmasCards', 40, 'prc5_ChristmasCardAssociate3', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyChristmasCards', 50, 'prc5_ChristmasCardFieldRep', 0, 1, 1, 0
Go


UPDATE Custom_Lists SET Grip_AllowOrderBy='Y' WHERE GriP_GridName = 'PRAdCampaignGrid' AND grip_ColName = 'BlueprintsEdition'
Go

INSERT INTO PRBusinessEventType (prbt_BusinessEventTypeId, prbt_Name, prbt_PublishDefaultTime, prbt_IndustryTypeCode)
VALUES (42, 'Commenced Operations', '-1.000000', ',P,S,T,L,')
Go


/*
DECLARE @WorkDate date = GETDATE()
WHILE (DAY(@WorkDate) <> 26) BEGIN
	SET @WorkDate = DATEADD(day, -1, @WorkDate)
END


DECLARE @WorkDate2 datetime = @WorkDate
SET @WorkDate2 = DATEADD(minute, 1125, @WorkDate2)
DECLARE @WorkDate3 varchar(50) = CONVERT(varchar(25), @WorkDate2, 100)

EXEC usp_AccpacCreateDropdownValue 'LastBBScoreReportDate', @WorkDate3, 0, 'Last BBScore Report Date'
*/
Go

-- Add Nadine to the Rating Analyst group.  JEB and ZMC are part of this, so NCM can be as well.
DECLARE @ID int
EXEC usp_GetNextId 'Channel_Link', @ID output
INSERT INTO Channel_Link VALUES (1126, 2, 20, null, -1, GETDATE(), -1, GETDATE(), GETDATE(), NULL);  -- NCM
Go


EXEC usp_AddCustom_Screens 'PROpportunitySearchBox', 60, 'comp_PRListingCityID', 1, 1, 1
EXEC usp_AddCustom_Screens 'PROpportunitySearchBox', 65, 'prst_StateID', 0, 1, 1
Go

EXEC usp_AccpacCreateField @EntityName = 'PRTradeReport', 
                           @FieldName = 'HasComments',
                           @Caption = 'Comments',
                           @AccpacEntryType = 45,
                           @AccpacEntrySize = 0,
                           @DBFieldType = 'nchar',
                           @DBFieldSize = 1,
                           @AllowNull = 'Y',
                           @IsRequired = 'N', 
                           @AllowEdit = 'Y', 
                           @IsUnique = 'N',
                           @DefaultValue = NULL,    
			               @SkipColumnCreation = 'Y'

EXEC usp_AddCustom_Lists 'PRTradeReportOnGrid', 130, 'HasComments', null, null, null, 'CENTER'
EXEC usp_DeleteCustom_List 'PRTradeReportOnGrid', 'prtr_Level1ClassificationValues'
Go



INSERT INTO PRCreditWorthRating (prcw_CreditWorthRatingId, prcw_Name, prcw_Order, prcw_IndustryType, prcw_CreatedBy, prcw_CreatedDate)
  VALUES (79, '250,000M', 45, ',P,T,', -1, GETDATE());
INSERT INTO PRCreditWorthRating (prcw_CreditWorthRatingId, prcw_Name, prcw_Order, prcw_IndustryType, prcw_CreatedBy, prcw_CreatedDate)
  VALUES (80, '500,000M', 46, ',P,T,', -1, GETDATE());
INSERT INTO PRCreditWorthRating (prcw_CreditWorthRatingId, prcw_Name, prcw_Order, prcw_IndustryType, prcw_CreatedBy, prcw_CreatedDate)
  VALUES (81, '250,000K', 45, ',L,', -1, GETDATE());
INSERT INTO PRCreditWorthRating (prcw_CreditWorthRatingId, prcw_Name, prcw_Order, prcw_IndustryType, prcw_CreatedBy, prcw_CreatedDate)
  VALUES (82, '500,000K', 46, ',L,', -1, GETDATE());
Go

EXEC usp_AddCustom_Screens 'PRPACALicenseSummary', 57, 'prpa_Email', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPACALicenseSummary', 58, 'prpa_WebAddress', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPACALicenseSummary', 59, 'prpa_Fax', 0, 1, 1, 0
Go

UPDATE custom_edits SET colp_SearchSQL='pers_PRUnconfirmed IS NULL AND peli_PRStatus=''1''' WHERE colp_colpropsid=12695
Go