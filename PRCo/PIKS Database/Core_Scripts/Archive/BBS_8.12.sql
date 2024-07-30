--8.12 Release
USE CRM


EXEC usp_TravantCRM_CreateIntegerField 'PRBBScore', 'prbs_ARLag', 'AR Lag'
EXEC usp_TravantCRM_CreateIntegerField 'PRBBScore', 'prbs_ARNage', 'AR Nage'
EXEC usp_TravantCRM_CreateIntegerField 'PRBBScore', 'prbs_ARScore', 'AR Score'
EXEC usp_TravantCRM_CreateNumericField 'PRBBScore', 'prbs_ARNagePercentile', 'AR Nage Percentile'
EXEC usp_TravantCRM_CreateNumericField 'PRBBScore', 'prbs_ARWeight', 'AR Weight'
EXEC usp_TravantCRM_CreateNumericField 'PRBBScore', 'prbs_ARStatisticalWeight', 'Statistical AR Weight'


EXEC usp_TravantCRM_CreateIntegerField 'PRBBScore', 'prbs_SurveyLag', 'Survey Lag'
EXEC usp_TravantCRM_CreateIntegerField 'PRBBScore', 'prbs_SurveyNage', 'Survey Nage'
EXEC usp_TravantCRM_CreateIntegerField 'PRBBScore', 'prbs_SurveyScore', 'Survey Score'
EXEC usp_TravantCRM_CreateNumericField 'PRBBScore', 'prbs_SurveyNagePercentile', 'Survey Nage Percentile'
EXEC usp_TravantCRM_CreateNumericField 'PRBBScore', 'prbs_SurveyWeight', 'Survey Weight'
EXEC usp_TravantCRM_CreateNumericField 'PRBBScore', 'prbs_SurveyStatisticalWeight', 'Statistical Survey Weight'


--PRBBScoreGridProduce
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBBScoreGrid'
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBBScoreGridProduce'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBBScoreGridProduce', 'List', 'PRBBScore', 'N', 0, 'PRBBScore'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 10, 'prbs_Date', null, 'Y'
exec usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 20, 'prbs_BBScore', null, 'Y', null, 'CENTER', 'Custom', '', '', 'PRCompany/PRBBScore.asp', 'prbs_BBScoreId'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 30, 'prbs_Deviation', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 40, 'prbs_SurveyScore', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 50, 'prbs_SurveyLag', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 60, 'prbs_SurveyNage', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 70, 'prbs_SurveyNagePercentile', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 80, 'prbs_SurveyWeight', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 90, 'prbs_ARScore', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 100, 'prbs_ARLag', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 110, 'prbs_ARNage', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 120, 'prbs_ARNagePercentile', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 130, 'prbs_ARWeight', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 140, 'prbs_ConfidenceScore', null, 'Y', null, 'CENTER'
EXEC usp_TravantCRM_AddCustom_Lists 'PRBBScoreGridProduce', 150, 'prbs_MinimumTradeReportCount', null, 'Y', null, 'CENTER'

--EXEC usp_TravantCRM_GetBlockInfo 'PRBBScoreNewEntry'
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRBBScoreSummary'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRBBScoreSummary', 'Screen', 'PRBBScore', 'N', 0, 'PRBBScore'
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 10, 'prbs_CompanyId', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 20, 'prbs_Date', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 30, 'prbs_RunDate', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 40, 'prbs_Current', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 50, 'prbs_BBScore', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 60, 'prbs_SurveyScore', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 70, 'prbs_ARScore', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 80, 'prbs_Deviation', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 90, 'prbs_SurveyWeight', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 100, 'prbs_ARWeight', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 110, 'prbs_MinimumTradeReportCount', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 120, 'prbs_SurveyNage', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 130, 'prbs_ARNage', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 140, 'prbs_Model', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 150, 'prbs_SurveyNagePercentile', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRBBScoreSummary', 160, 'prbs_ARNagePercentile', 0, 1, 1, 0
Go


EXEC usp_TravantCRM_AddCustom_Screens 'PRCompanyInfo', 90, 'comp_PROriginalName', 1, 1, 2, 0
Go