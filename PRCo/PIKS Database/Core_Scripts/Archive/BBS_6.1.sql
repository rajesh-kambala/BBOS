EXEC usp_AccpacCreateSearchSelectField 'PRSurveyResponse', 'prsr_PublicationArticleID', 'Publication Article', 'PRPublicationArticle', 100 


EXEC usp_AddCustom_Screens 'PRPATraining', 10, 'prpbar_Name',             1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 20, 'prpbar_Sequence',         0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 30, 'prpbar_Abstract',         1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 40, 'prpbar_PublishDate',      1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 50, 'prpbar_MediaTypeCode',    0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 60, 'prpbar_CategoryCode',     1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 70, 'prpbar_Length',           0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 80, 'prpbar_FileName',         1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRPATraining', 90, 'prpbar_CoverArtFileName', 1, 1, 2, 0
Go

