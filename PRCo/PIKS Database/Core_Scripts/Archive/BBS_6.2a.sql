EXEC usp_AccpacCreateMultilineField 'PRSSFile', 'prss_StatusDescription', 'Status Description', 100
EXEC usp_AccpacCreateMultilineField 'PRSSFile', 'prss_PublishedNotes', 'Published Notes', 100
EXEC usp_AccpacCreateMultilineField 'PRSSFile', 'prss_PublishedIssueDesc', 'Published Issue Description', 100

EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 100, 'prss_StatusDescription', 1, 1, 2
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 110, 'prss_PublishedNotes', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 270, 'prss_PublishedIssueDesc', 1, 1, 2