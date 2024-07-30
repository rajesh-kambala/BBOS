UPDATE Custom_ScreenObjects
  SET Cobj_CustomContent = CAST(Cobj_CustomContent as varchar(max)) + '<link rel="stylesheet" href="/CRM/prco.css">'
WHERE Cobj_TableID IN (307,308,56,58,10381,238)
Go

EXEC usp_AccpacCreateCheckboxField  'PRWebUser', 'prwu_SecurityDisabled', 'Security Disable'
EXEC usp_AccpacCreateDateTimeField	'PRWebUser', 'prwu_SecurityDisabledDate', 'Security Disabled Date/Time'
EXEC usp_AccpacCreateTextField		'PRWebUser', 'prwu_SecurityDisabledReason', 'Service Code', 100, 100
Go

UPDATE Custom_Captions
   SET capt_us = 'Can Use Business Reports'
WHERE capt_code = 'peli_PRUseServiceUnits'

UPDATE Custom_Captions
   SET capt_us = 'Do not charge a Business Report'
WHERE capt_code = 'prbr_donotchargeunits'
Go

UPDATE Custom_Captions
   SET capt_us = 'Business Reports Allocated'
WHERE capt_code = 'prun_UnitsAllocated'

UPDATE Custom_Captions
   SET capt_us = 'Business Reports Used'
WHERE capt_code = 'UnitsUsed'


UPDATE Custom_Captions
   SET capt_us = 'Business Reports Remaining'
WHERE capt_code = 'prun_UnitsRemaining'

UPDATE Custom_Captions
   SET capt_us = 'Can Use Business Reports'
WHERE capt_code = 'peli_PRUseServiceUnits'


EXEC usp_DeleteCustom_List 'PRServiceUnitUsageHistoryGrid', 'prsuu_Units'
EXEC usp_AddCustom_Lists 'PRServiceUnitUsageHistoryGrid', 5, 'prsuu_TransactionTypeCode', null, 'Y'
UPDATE custom_screenobjects SET cobj_EntityName = 'vPRServiceUnitUsageHistoryCRM' WHERE cobj_TableID = 10827
EXEC usp_DefineCaptions 'vPRServiceUnitUsageHistoryCRM', 'Purchased Reports', 'Purchased Reports', null, null, null, null



EXEC usp_DeleteCustom_Screen 'PRServiceUnitUsageSummary', 'prsuu_Units'
EXEC usp_DeleteCustom_Screen 'PRServiceUnitUsageSummary', 'prsuu_TransactionTypeCode'

UPDATE Custom_Captions Set capt_us = 'No Business Report Allocations' WHERE capt_CaptionID = 90208
UPDATE Custom_Captions Set capt_us = 'Business Report Allocation' WHERE capt_CaptionID = 90214
UPDATE Custom_Captions Set capt_us = 'Business Report Allocation' WHERE capt_CaptionID = 90210
UPDATE Custom_Captions Set capt_us = 'Business Report Allocations' WHERE capt_CaptionID = 90209
Go


EXEC usp_AddCustom_Lists 'PRVICallQueue', 25, 'comp_PRLocalSource', null, 'Y'
EXEC usp_AddCustom_Screens 'PRVIResponder', 80, 'comp_PRLocalSource', 0, 1, 1, 0
Go

EXEC usp_AccpacCreateCheckboxField  'PRSearchAuditTrail', 'prsat_IsLocalSource', 'Local Source Search'
Go

EXEC usp_DeleteCustom_Screen 'PRCreditSheetPublishingStatus', 'prcs_EBBUpdatePubDate'
EXEC usp_DeleteCustom_Screen 'PRCreditSheetPublishingStatus', 'prcs_AUSDate'
Go

EXEC usp_AccpacCreateTable @EntityName='PRUnloadHours', @ColPrefix='pruh', @IDField='pruh_UnloadHoursID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRUnloadHours', 'pruh_UnloadHoursID', 'Unload Hours ID'
EXEC usp_AccpacCreateSearchSelectField 'PRUnloadHours', 'pruh_CompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateTextField         'PRUnloadHours', 'pruh_LineContent', 'Line Content', 100, 100
Go

EXEC usp_AccpacCreateIntegerField  'PRCompanyBrand', 'prc3_PRReplicatedFromId', 'Replicated From'
Go
