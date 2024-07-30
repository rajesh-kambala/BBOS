EXEC usp_AccpacCreateCheckboxField  'PRPublicationArticle', 'prpbar_BBOSProducePinned', 'Pin to BBOS Produce Home Page'
EXEC usp_AccpacCreateCheckboxField  'PRPublicationArticle', 'prpbar_BBOSLumberPinned', 'Pin to BBOS Lumber Home Page'
EXEC usp_AddCustom_Screens 'PRPublicationArticleEntry', 105, 'prpbar_MediaTypeCode', 1, 1, 1, 0
Go



EXEC usp_AddCustom_Screens 'PRNewsArticleEntry', 90, 'prpbar_BBOSProducePinned', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRNewsArticleEntry', 95, 'prpbar_BBOSLumberPinned', 0, 1, 1, 0
Go

EXEC usp_AccpacCreateTextField 'PRWebUserCustomData', 'prwucd_Value', 'Value', 250, 250
Go


EXEC usp_AccpacCreateCheckboxField  'Company', 'comp_PRRetailerOnlineOnly', 'Retailer - Online Only'
Go

EXEC usp_AccpacCreateTable @EntityName='PRWebUserWidget', @ColPrefix='prwuw', @IDField='prwuw_WebUserWidgetID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRWebUserWidget', 'prwuw_WebUserWidgetID', 'Web User Widget ID'
EXEC usp_AccpacCreateSearchSelectField 'PRWebUserWidget', 'prwuw_WebUserID', 'PRWebUser', 'PRWebUser', 100 
EXEC usp_AccpacCreateTextField         'PRWebUserWidget', 'prwuw_WidgetName', 'Widget', 50, 125
EXEC usp_AccpacCreateIntegerField      'PRWebUserWidget', 'prwuw_Sequence', 'Sequence'
Go

EXEC usp_AccpacCreateMultiselectField 'PRAdCampaign', 'pradc_IndustryType', 'Industry Type', comp_PRIndustryType, 4
EXEC usp_AccpacCreateMultiselectField 'PRAdCampaign', 'pradc_Language', 'Language', prwu_Culture, 2
EXEC usp_AccpacCreateIntegerField     'PRAdCampaign', 'pradc_Sequence', 'Sequence'
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 200, 'pradc_IndustryType', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 210, 'pradc_Language', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRAdCampaignNewEntry', 220, 'pradc_Sequence', 1, 1, 1, 0
Go

EXEC usp_AccpacCreateSelectField 'PRAdCampaign', 'pradc_PublicationCode', 'Publication', pradc_PublicationCode, 4
--EXEC usp_AddCustom_Screens 'PRAdCampaignPUB', 5, 'pradc_PublicationCode', 1, 1, 1, 0
GO

EXEC usp_AccpacCreateTable @EntityName='PRCSGPerson', @ColPrefix='prcsgp', @IDField='prcsgp_PersonID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRCSGPerson', 'prcsgp_PersonID', 'Person ID'
EXEC usp_AccpacCreateIntegerField      'PRCSGPerson', 'prcsgp_CSGID', 'CSG ID'
EXEC usp_AccpacCreateTextField         'PRCSGPerson', 'prcsgp_CSGPersonID', 'CSG Person ID', 50, 50
EXEC usp_AccpacCreateTextField         'PRCSGPerson', 'prcsgp_Email', 'Title', 100, 255
EXEC usp_AccpacCreateTextField         'PRCSGPerson', 'prcsgp_FirstName', 'First Name', 50, 50
EXEC usp_AccpacCreateTextField         'PRCSGPerson', 'prcsgp_LastName', 'Last Name', 50, 50
EXEC usp_AccpacCreateTextField         'PRCSGPerson', 'prcsgp_MiddleInitial', 'Middle Initial', 5, 5
EXEC usp_AccpacCreateTextField         'PRCSGPerson', 'prcsgp_Suffix', 'Suffix', 25, 25
EXEC usp_AccpacCreateTextField         'PRCSGPerson', 'prcsgp_Title', 'Title', 50, 50
EXEC usp_AccpacCreateTextField         'PRCSGPerson', 'prcsgp_Email', 'Title', 100, 255
Go

DECLARE @WorkDate datetime = GETDATE()
DECLARE @WorkDate3 varchar(50) = CONVERT(varchar(25), @WorkDate, 100)
SELECT @WorkDate
EXEC usp_AccpacCreateDropdownValue 'ARAnalysisReportLastRunDate', @WorkDate3, 0, 'Last AR Analysis Report Date'
Go

--
--  Change the server setting to Central
UPDATE Custom_SysParams SET Parm_Value = '-06:00_2', Parm_Component='Changed' WHERE Parm_name = 'ServerTimeZone'
UPDATE usersettings SET uset_value = '-06:00_2' where uset_key = 'NSet_TimeZoneDelta' AND uset_value <> '-06:00_2';
UPDATE usersettings SET uset_value = '-05:00' WHERE uset_key = 'NSet_TimeZoneDelta' AND uset_userid  IN (134, 1056); 
UPDATE usersettings SET uset_value = '-08:00' WHERE uset_key = 'NSet_TimeZoneDelta' AND uset_userid  = 1060;
Go


EXEC usp_AccpacCreateCheckboxField     'Company', 'comp_PRImporter', 'Is Importer'
EXEC usp_AccpacCreateCheckboxField     'Company', 'comp_PRIsIntlTradeAssociation', 'Is Intl Trade Association'
EXEC usp_AccpacCreateCheckboxField     'Company', 'comp_PRExcludeFromIntlTA', 'Do Not Match To Intl Trade Assoc'
EXEC usp_AccpacCreateCheckboxField     'PRCompanyTradeAssociation', 'prcta_IsIntlTradeAssociation', 'Is Intl Trade Association'
EXEC usp_AccpacCreateCheckboxField     'Person', 'pers_PRIsIntlTradeAssociation', 'Is Intl Trade Association'

--EXEC usp_AccpacGetBlockInfo 'PRCompanyTradeAssociationGrid'
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 75, 'comp_PRLegalName', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 77, 'comp_PRAccountTier', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 78, 'comp_PRIsIntlTradeAssociation', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 80, 'comp_Name', 1, 1, 2, 0
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 82, 'comp_PRExcludeFromIntlTA', 0, 1, 1, 0

EXEC usp_AddCustom_Lists 'PRCompanyTradeAssociationGrid', 30, 'prcta_IsIntlTradeAssociation', null, 'Y', null, 'CENTER'
EXEC usp_AddCustom_Lists 'PRCompanyTradeAssociationGrid', 40, 'prcta_Disabled', null, 'Y', null, 'CENTER'

GO

ALTER TABLE PRWebUser DROP Constraint DF__PRWebUser__prwu___36B2B8F1
EXEC usp_AccpacCreateTextField     'PRWebuser', 'prwu_LastName', 'Last Name', 30, 50
Go

EXEC usp_AccpacCreateTextField     'PRCSGData', 'prcsgd_Value', 'Value', 100, 1000
Go

EXEC usp_AccpacCreateTable @EntityName='PRWordPressPostCompany', @ColPrefix='prwpc', @IDField='prwpc_WordPressPostCompanyID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRWordPressPostCompany', 'prwpc_WordPressPostCompanyID', 'WordPress Post Company ID'
EXEC usp_AccpacCreateSearchSelectField 'PRWordPressPostCompany', 'prwpc_CompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateIntegerField      'PRWordPressPostCompany', 'prwpc_PostID', 'WordPress PostID'
Go

EXEC usp_AccpacCreateSelectField 'PRPublicationArticleRead', 'prpar_PublicationCode', 'Publication Code', 'prpbar_PublicationCode'
EXEC usp_AccpacCreateDropdownValue 'prpbar_PublicationCode', 'WPBA', 150, 'Blueprints Quarterly Journal' 

Use WordPress
IF NOT EXISTS (SELECT 'x' FROM sys.fulltext_indexes where object_id = object_id('wp_Posts')) BEGIN
      
	CREATE FULLTEXT INDEX ON [dbo].[wp_posts](
		   [post_content] LANGUAGE 'English', 
		   [post_title] LANGUAGE 'English')
		   KEY INDEX [wp_posts_ID]ON ([wp_posts], FILEGROUP [PRIMARY])
		   WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
END
GO

USE CRM
--6.1.3.1
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=63
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=9
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=13
--UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=32	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=18	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=19	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=20	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=17	
--UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=31	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=28	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=15	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=48	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=60	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=84	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=85	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=103	
UPDATE PRBBOSPrivilege SET AccessLevel=50 WHERE BBOSPrivilegeID=66  
GO

--6.1.3.2
INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES('P', 200, 'CompanySearchByIndustry', null, 1, 0)
INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES('S', 200, 'CompanySearchByIndustry', null, 1, 0)
INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES('T', 200, 'CompanySearchByIndustry', null, 1, 0)
GO

--6.1.4.1
UPDATE Company 
   SET comp_PRImporter = 'Y' 
  FROM PRCompanyClassification
 WHERE prc2_CompanyId = comp_CompanyID
   AND prc2_ClassificationId = 220
GO



EXEC usp_AccpacCreateTextField 'PRWebUserSearchCriteria', 'prsc_Name', 'prsc Name', 200, 200


EXEC usp_AccpacCreateDropdownValue 'ITAMessageCenterMsg', 'Message', 0, ''