EXEC usp_AccpacCreateCheckboxField  'Company', 'comp_PRExcludeFromLocalSource', 'Do Not Match to Local Source'

EXEC usp_AddCustom_Screens 'PRCompanyInfo', 72, 'comp_PRExcludeFromLocalSource', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 75, 'comp_PRLegalName', 1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 77, 'comp_PRAccountTier', 0, 1, 1, 0
Go

EXEC usp_AccpacCreateTextField		'PRWebUser', 'prwu_SecurityDisabledReason', 'Security Disabled Reason', 100, 100

EXEC usp_AccpacGetBlockInfo 'PRWebUserInfo_PIKS'
EXEC usp_AddCustom_Screens 'PRWebUserInfo_PIKS', 100, 'prwu_SecurityDisabled', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRWebUserInfo_PIKS', 110, 'prwu_SecurityDisabledDate', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRWebUserInfo_PIKS', 120, 'prwu_SecurityDisabledReason', 0, 1, 1, 0

EXEC usp_AccpacGetBlockInfo 'PRWebUserEntry'
EXEC usp_AddCustom_Screens 'PRWebUserEntry', 55, 'prwu_SecurityDisabled', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRWebUserEntry', 65, 'prwu_SecurityDisabledDate', 0, 1, 1, 0, null, null, null, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRWebUserEntry', 75, 'prwu_SecurityDisabledReason', 0, 1, 1, 0, null, null, null, 'ReadOnly=true;'
Go

