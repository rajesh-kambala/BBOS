--
-- Full Text Index for the BBOS Learning Center
--
EXEC [CRM].[dbo].[sp_fulltext_database] @action = 'enable'

IF NOT EXISTS (SELECT * FROM sysfulltextcatalogs ftc WHERE ftc.name = N'LearningCenter') BEGIN
	CREATE FULLTEXT CATALOG [LearningCenter]
END

IF not EXISTS (SELECT * FROM sys.fulltext_indexes fti WHERE fti.object_id = OBJECT_ID(N'[dbo].[PRPublicationArticle]')) BEGIN
	CREATE FULLTEXT INDEX ON [dbo].[PRPublicationArticle](
	[prpbar_Abstract] LANGUAGE [English], 
	[prpbar_Body] LANGUAGE [English], 
	[prpbar_FileName] LANGUAGE [English], 
	[prpbar_Name] LANGUAGE [English])
	KEY INDEX [PK__PRPublicationArt__1922560A] ON [LearningCenter]
	WITH CHANGE_TRACKING AUTO
END
--
-- END Full Text Index for the BBOS Learning Center
--

