EXEC usp_AccpacCreateNumericField 'PRBBScore', 'prbs_IndustryAve', 'Industry Average'
EXEC usp_AccpacCreateIntegerField 'PRBBScore', 'prbs_IndustryPercentile', 'Industry Percentile'
Go


EXEC usp_AccpacCreateNumericField 'Address', 'addr_PRLatitude', 'Latitude'
EXEC usp_AccpacCreateNumericField 'Address', 'addr_PRLongitude', 'Longitude'
Go


EXEC usp_AccpacDropTable 'PRLRLCycle'
EXEC usp_AccpacCreateTable @EntityName='PRLRLCycle', @ColPrefix='prlrlc', @IDField='prlrlc_LRLCycleID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRLRLCycle', 'prlrlc_LRLCycleID', 'LRL Cycle ID'
EXEC usp_AccpacCreateSelectField       'PRLRLCycle', 'prlrlc_IndustryTypeCode', 'Industry Type Code', 'prlrlc_IndustryTypeCode'
EXEC usp_AccpacCreateSelectField       'PRLRLCycle', 'prlrlc_ServiceTypeCode', 'Status Code', 'prlrlc_ServiceTypeCode'
EXEC usp_AccpacCreateDateField		   'PRLRLCycle', 'prlrlc_CycleStartDate', 'Start Date Time'
EXEC usp_AccpacCreateDateField         'PRLRLCycle', 'prlrlc_CycleEndDate', 'End Date Time'
EXEC usp_AccpacCreateIntegerField      'PRLRLCycle', 'prlrlc_CycleCount', 'Cycle Count'
EXEC usp_AccpacCreateDateField		   'PRLRLCycle', 'prlrlc_GapStartDate', 'Gap Start Date Time'
EXEC usp_AccpacCreateDateField         'PRLRLCycle', 'prlrlc_GapEndDate', 'Gap End Date Time'



EXEC usp_AccpacCreateIntegerField      'PRLRLBatch', 'prlrlb_LRLCycleID',     'LRL Cycle ID'
EXEC usp_AccpacCreateIntegerField      'PRLRLBatch', 'prlrlb_MemberCount',    'Member Count'
EXEC usp_AccpacCreateIntegerField      'PRLRLBatch', 'prlrlb_NonMemebrCount', 'Non Member Count'
EXEC usp_AccpacCreateIntegerField      'PRLRLBatch', 'prlrlb_TotalSentCount', 'Total Sent Count'
EXEC usp_AccpacCreateIntegerField      'PRLRLBatch', 'prlrlb_RemainingCount', 'Remaining Count'
Go

EXEC usp_DeleteCustom_List 'PRLRLBatchGrid', 'prlrlb_Criteria'
EXEC usp_DeleteCustom_List 'PRLRLBatchGrid', 'prlrlb_LetterType'
EXEC usp_DeleteCustom_List 'PRLRLBatchGrid', 'prlrlb_BatchType'
EXEC usp_DeleteCustom_List 'PRLRLBatchGrid', 'prlrlb_CreatedBy'

EXEC usp_AddCustom_Lists 'PRLRLBatchGrid', 10, 'prlrlb_CreatedDate', null, 'Y', 'Y'
EXEC usp_AddCustom_Lists 'PRLRLBatchGrid', 20, 'prlrlb_BatchName', null, 'Y'
EXEC usp_AddCustom_Lists 'PRLRLBatchGrid', 40, 'prlrlb_Count', null, 'Y'
EXEC usp_AddCustom_Lists 'PRLRLBatchGrid', 50, 'prlrlb_MemberCount', null, 'Y'
EXEC usp_AddCustom_Lists 'PRLRLBatchGrid', 60, 'prlrlb_NonMemebrCount', null, 'Y'
EXEC usp_AddCustom_Lists 'PRLRLBatchGrid', 70, 'prlrlb_TotalSentCount', null, 'Y'
EXEC usp_AddCustom_Lists 'PRLRLBatchGrid', 80, 'prlrlb_RemainingCount', null, 'Y'
UPDATE custom_lists SET grip_DefaultOrderBy = 'Y', GriP_OrderByDesc='Y' WHERE grip_GridName = 'PRLRLBatchGrid' AND grip_ColName='prlrlb_CreatedDate';
Go




DELETE FROM PRLRLCycle

-- Produce Spring
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount)
VALUES ('P', 'B', '2015-1-20', '2015-7-20', 26);

-- Produce Fall
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount, prlrlc_GapStartDate, prlrlc_GapEndDate)
VALUES ('P', 'B', '2015-7-21', '2016-1-18', 22, '2015-12-8', '2016-1-4');

-- Lumber All Year Non-Members
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount)
VALUES ('L', 'N', '2015-1-20', '2015-12-2', 46);

-- Lumber Spring Members
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount)
VALUES ('L', 'M', '2015-3-17', '2015-3-23', 1);

-- Lumber Fall Members
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount)
VALUES ('L', 'M', '2015-9-15', '2015-9-21', 1);

Go


EXEC usp_AccpacCreateDateTimeField 'PRWebUserNote', 'prwun_NoteUpdatedDateTime', 'Note Updated Date Time'
EXEC usp_AccpacCreateIntegerField  'PRWebUserNote', 'prwun_NoteUpdatedBy', 'Note Updated By'

EXEC usp_AccpacCreateDateField	   'PRWebUserNoteReminder', 'prwunr_Date', 'Date'
EXEC usp_AccpacCreateDateField	   'PRWebUserNoteReminder', 'prwunr_DateUTC', 'Date UTC'
EXEC usp_AccpacCreateSelectField   'PRWebUserNoteReminder', 'prwunr_Hour', 'Hour', 'prwun_Hour'
EXEC usp_AccpacCreateSelectField   'PRWebUserNoteReminder', 'prwunr_Minute', 'Minute', 'prwun_Minute'
EXEC usp_AccpacCreateSelectField   'PRWebUserNoteReminder', 'prwunr_AMPM', 'AM/PM', 'prwun_AMPM'
EXEC usp_AccpacCreateSelectField   'PRWebUserNoteReminder', 'prwunr_Timezone', 'Time Zone', 'prwu_Timezone'
Go





--SELECT * FROM custom_captions WHERE capt_us LIKE '%integrity%'
UPDATE Custom_Captions SET capt_us = 'Trade Practices Rating' WHERE capt_CaptionID=7708
UPDATE Custom_Captions SET capt_us = 'Trade Practices' WHERE capt_CaptionID=7709
UPDATE Custom_Captions SET capt_us = 'Suppress Trade Practices Rating' WHERE capt_CaptionID=7739
UPDATE Custom_Captions SET capt_us = '3 Mo Trade Practices Rating' WHERE capt_CaptionID=8085
UPDATE Custom_Captions SET capt_us = 'Trade Practices' WHERE capt_CaptionID=7709
UPDATE Custom_Captions SET capt_us = 'Trade Practices' WHERE capt_CaptionID=9290
UPDATE Custom_Captions SET capt_us = 'Trade Practices' WHERE capt_CaptionID=9322
UPDATE Custom_Captions SET capt_us = 'No Trade Practice Ratings' WHERE capt_CaptionID=11570
UPDATE Custom_Captions SET capt_us = 'Trade Practice Ratings' WHERE capt_CaptionID=11571
UPDATE Custom_Captions SET capt_us = 'Trade Practice Rating' WHERE capt_CaptionID=11572
UPDATE Custom_Captions SET capt_us = 'Trade Practices Response Count' WHERE capt_CaptionID=58179
UPDATE Custom_Captions SET capt_us = 'Target # of Trade Practices Reports' WHERE capt_CaptionID=58151
Go


EXEC usp_AccpacCreateDateField 'PRAdCampaign', 'pradc_SoldDate', 'Sold Date'
Go
EXEC usp_AddCustom_Screens 'PRAdCampaignBP', 109, 'pradc_SoldDate', 0, 1, 1

EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 70, 'pradc_Renewal', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 72, 'pradc_SoldDate', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 74, 'pradc_Cost', 0, 1, 1

EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 120, 'pradc_SoldDate', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 140, 'pradc_Cost', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 150, 'pradc_Notes', 1, 3, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 160, 'pradc_Discount', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 170, 'pradc_Terms', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 180, 'pradc_Renewal', 1, 1, 1
Go

UPDATE Custom_Captions SET Capt_US = 'No Court Cases' WHERE Capt_CaptionId = 126580
UPDATE Custom_Captions SET Capt_US = 'Court Case' WHERE Capt_CaptionId = 126582
UPDATE Custom_Captions SET Capt_US = 'Court Cases' WHERE Capt_CaptionId = 126581
UPDATE Custom_Captions SET Capt_US = 'Court Case' WHERE Capt_CaptionId = 126586
Go


EXEC usp_AccpacCreateTextField      'PRWebUser', 'prwu_MobileGUID', 'Mobile GUID', 50, 50
EXEC usp_AccpacCreateDateTimeField  'PRWebUser', 'prwu_MobileGUIDExpiration', 'Mobile GUID Expiration'
Go


EXEC usp_AccpacDropTable 'PRCompanyRating'
EXEC usp_AccpacCreateTable @EntityName='PRCompanyRating', @ColPrefix='prcra', @IDField='prcra_CompanyRatingID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRCompanyRating', 'prcra_CompanyRatingID', 'Company Rating ID'
EXEC usp_AccpacCreateSearchSelectField 'PRCompanyRating', 'prcra_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateTextField         'PRCompanyRating', 'prcra_RatingLine', 'Rating Line', 50, 100
EXEC usp_AccpacCreateIntegerField      'PRCompanyRating', 'prcra_RatingID', 'Rating ID'
EXEC usp_AccpacCreateCheckboxField     'PRCompanyRating', 'prcra_IsHQRating', 'Is HQ Rating'
Go

EXEC usp_DeleteCustom_Screen 'PRBusinessEvent_Core', 'prbe_CreditSheetPublish'
Go