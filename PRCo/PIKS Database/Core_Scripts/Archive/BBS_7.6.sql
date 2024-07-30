EXEC usp_AccpacCreateCheckboxField 'Company', 'comp_PRARReportAccess', 'Allow AR Report Access'
EXEC usp_AccpacCreateCheckboxField 'Company', 'comp_PRHasCustomPersonSort', 'Has Custom Person Sort'
Go

--EXEC usp_AccpacGetBlockInfo 'PRCompanyInfo'
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 198, 'comp_PRARReportAccess', 0, 1, 1
Go


EXEC usp_AccpacCreateTextField     'PRLocalSource', 'prls_PRMMWID', 'MMW ID', 25, 50
--DELETE FROM PRLocalSource WHERE prls_LocalSourceID IN (14380, 13360, 12603, 4332, 14213, 17264, 6176, 13263, 16576, 15810, 8599, 8476)
Go

UPDATE Custom_ScreenObjects
   SET cobj_CustomContent = '<script type="text/javascript" src="/CRM/CustomPages/PRCoGeneral.js"></script><script "text/javascript" src="/CRM/CustomPages/PRGeneral/PRInteraction.js"></script><script type="text/javascript">RedirectInteraction();hideDropdownValues();</script>'
 WHERE cobj_TableID=56
Go


EXEC usp_AccpacCreateSelectField 'PRWebUser', 'prwu_ARReportsThrehold', 'Default AR Reports Age', 'prwu_ARReportsThrehold'
Go

EXEC usp_AccpacCreateCheckboxField  'PRCompanyInfoProfile', 'prc5_ReceiveARReminder', 'Receives AR Reminders'
EXEC usp_AddCustom_Screens 'PRCompanyInfoProfileFlags', 10, 'prc5_ARSubmitter', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRCompanyInfoProfileFlags', 20, 'prc5_ReceiveARReminder', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRCompanyInfoProfileFlags', 30, 'prc5_CLSubmitter', 0, 1, 1

UPDATE Custom_Captions SET capt_US = 'RL Submitter' WHERE capt_code = 'prc5_CLSubmitter'
Go

EXEC usp_AddCustom_Lists 'PersonAdvancedSearchGrid', 235, 'peli_PRStatus', null, null
Go

ALTER TABLE PRSSFile ALTER COLUMN prss_RecordOfActivity VARCHAR(MAX)
Go

UPDATE Custom_Edits SET colp_LookupFamily = 'PRCompanySearch' WHERE colp_ColPropsID = 15669
UPDATE Custom_Edits SET colp_LookupFamily = 'PRCompanySearch' WHERE colp_ColPropsID = 15670
Go

EXEC usp_DeleteCustom_ScreenObject 'PRVICallQueueSearchBox'
EXEC usp_AddCustom_ScreenObjects 'PRVICallQueueSearchBox', 'SearchScreen', 'vPRVICallQueue', 'N', 0, 'vPRVICallQueue'
EXEC usp_AddCustom_Screens 'PRVICallQueueSearchBox', 10, 'comp_CompanyIdDisplay', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRVICallQueueSearchBox', 20, 'prtesr_ResponderCompanyID', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRVICallQueueSearchBox', 30, 'comp_PRListingCityID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRVICallQueueSearchBox', 40, 'prst_StateID', 0, 1, 1, 0

EXEC usp_AddCustom_Lists 'PRVICallQueue', 5, 'comp_CompanyIdDisplay', null, 'Y'
UPDATE custom_captions SET capt_us = 'BB ID#' WHERE capt_captionID=11153
Go

EXEC usp_AddCustom_Lists 'PRCompanyTerminalMarketGrid', 30, 'prtm_State', null, 'Y'
Go

EXEC usp_DeleteCustom_Screen 'PRTransactionNewEntry', 'prtx_RedbookDate'
Go

EXEC usp_AccpacCreateNumericField 'PRFinancial', 'prfs_MarketingAdvertisingExpense', 'Marketing/Advertising Expense'
EXEC usp_AddCustom_Screens 'PRFinancialDepreciation', 30, 'prfs_MarketingAdvertisingExpense', 1, 1, 1, 0
Go
 
EXEC usp_AccpacCreateIntegerField  'PRClassification', 'prcl_CompanyCountIncludeLocalSource', 'Count with LSS Data'
Go