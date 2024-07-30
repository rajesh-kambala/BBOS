EXEC usp_AccpacDropField 'Email', 'emai_PRDefault'

EXEC usp_AccpacDropField 'PRPublicationArticle', 'prpbar_CompanyID1'
EXEC usp_AccpacDropField 'PRPublicationArticle', 'prpbar_CompanyID2'
EXEC usp_AccpacDropField 'PRPublicationArticle', 'prpbar_CompanyID3'

EXEC usp_AccpacDropView 'vPRContactInfo'
Go


ALTER TABLE [dbo].[PRARAgingDetail] DROP CONSTRAINT PK__PRARAgingDetail__49AEE81E
ALTER TABLE [dbo].[PRARAgingDetail] ADD CONSTRAINT PK_PRARAgingDetail PRIMARY KEY NONCLUSTERED (praad_ARAgingDetailId)

DROP INDEX [ndx_praad_ARAgingId] ON [dbo].[PRARAgingDetail] WITH ( ONLINE = OFF )
Go

EXEC usp_AccpacCreateIntegerField 'PRARAging', 'praa_Count', 'RecordCount', 10
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_Total', 'Total'
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_TotalCurrent', 'Total Current'
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_Total1to30', 'Total 1-30 ($)'
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_Total31to60', 'Total 31-60 ($)'
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_Total61to90', 'Total 61-90 ($)'
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_Total91Plus', 'Total 91+ ($)'
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_Total0to29', 'Total 0-29 ($)'
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_Total30to44', 'Total 30-44 ($)'
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_Total45to60', 'Total 45-60 ($)'
EXEC usp_AccpacCreateNumericField 'PRARAging', 'praa_Total61Plus', 'Total 61+ ($)'

EXEC usp_AddCustom_Screens 'PRARAgingDetailNewEntry', 100, 'praad_AmountCurrent'
EXEC usp_AddCustom_Screens 'PRARAgingDetailNewEntry', 110, 'praad_Amount1to30'
EXEC usp_AddCustom_Screens 'PRARAgingDetailNewEntry', 120, 'praad_Amount31to60'
EXEC usp_AddCustom_Screens 'PRARAgingDetailNewEntry', 130, 'praad_Amount61to90'
EXEC usp_AddCustom_Screens 'PRARAgingDetailNewEntry', 140, 'praad_Amount91Plus'
Go  



/* New Table - PRListing */
EXEC usp_AccpacCreateTable @EntityName='PRListing', @ColPrefix='prlst', @IDField='prlst_ListingID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyIdentityField  'PRListing', 'prlst_ListingID', 'Listing ID';
EXEC usp_AccpacCreateSearchSelectField 'PRListing', 'prlst_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateTextField         'PRListing', 'prlst_Listing', 'Listing', 500, 8000;


DECLARE @SQL VARCHAR(4000)
SET @SQL = 'ALTER TABLE PRListing DROP CONSTRAINT |ConstraintName| '
SET @SQL = REPLACE(@SQL, '|ConstraintName|', ( SELECT name FROM sysobjects WHERE xtype = 'PK' AND parent_obj = OBJECT_ID('PRListing')))
EXEC (@SQL)

ALTER TABLE [dbo].[PRListing] ADD CONSTRAINT PK_PRListing PRIMARY KEY NONCLUSTERED (prlst_ListingID)
Go

use CRMArchive

if Exists(select * from sys.columns where Name = N'praa_Count' and Object_ID = Object_ID(N'PRARAging')) BEGIN
  PRINT 'Columns Exist'
END	ELSE BEGIN

	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Count int
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Total numeric(24, 6)
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_TotalCurrent numeric(24, 6)
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Total1to30 numeric(24, 6)
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Total31to60 numeric(24, 6)
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Total61to90 numeric(24, 6)
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Total91Plus numeric(24, 6)
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Total0to29 numeric(24, 6)
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Total30to44 numeric(24, 6)
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Total45to60 numeric(24, 6)
	ALTER TABLE CRMArchive.dbo.PRARAging ADD praa_Total61Plus numeric(24, 6)
END
Go

use CRM

/* New Table - PRCompanyTradeShow */
EXEC usp_AccpacCreateTable @EntityName='PRCompanyTradeShow', @ColPrefix='prcts', @IDField='prcts_CompanyTradeShowID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyIdentityField  'PRCompanyTradeShow', 'prcts_CompanyTradeShowID', 'Company Trade Show ID';
EXEC usp_AccpacCreateSearchSelectField 'PRCompanyTradeShow', 'prcts_CompanyID', 'Company', 'Company', 50, 50 
EXEC usp_AccpacCreateTextField         'PRCompanyTradeShow', 'prcts_CompanyName', 'Tradeshow Provided Company Name', 50, 150;
EXEC usp_AccpacCreateTextField         'PRCompanyTradeShow', 'prcts_City', 'City', 50, 50;
EXEC usp_AccpacCreateTextField         'PRCompanyTradeShow', 'prcts_State', 'State', 2, 2;
EXEC usp_AccpacCreateTextField         'PRCompanyTradeShow', 'prcts_Phone', 'Phone', 20, 20;
EXEC usp_AccpacCreateTextField         'PRCompanyTradeShow', 'prcts_Year', 'Year', 4, 4;
EXEC usp_AccpacCreateTextField         'PRCompanyTradeShow', 'prcts_TradeShow', 'TradeShow', 50, 50;
EXEC usp_AccpacCreateTextField         'PRCompanyTradeShow', 'prcts_Booth', 'Booth', 50, 50;

DECLARE @SQL VARCHAR(4000)
SET @SQL = 'ALTER TABLE PRCompanyTradeShow DROP CONSTRAINT |ConstraintName| '
SET @SQL = REPLACE(@SQL, '|ConstraintName|', ( SELECT name FROM sysobjects WHERE xtype = 'PK' AND parent_obj = OBJECT_ID('PRCompanyTradeShow')))
EXEC (@SQL)

ALTER TABLE [dbo].[PRCompanyTradeShow] ADD CONSTRAINT PK_PRCompanyTradeShow PRIMARY KEY NONCLUSTERED (prcts_CompanyTradeShowID)
Go

DECLARE @ObjectName varchar(max), @EntityName varchar(max)
DECLARE @ScreenName varchar(max);

DECLARE @LN_New bit, @LN_Same bit, @RQ_Required bit, @RQ_NotRequired bit
SELECT @LN_New=1, @LN_Same=0, @RQ_Required=1, @RQ_NotRequired=0
SET @ObjectName = 'PRCompanyTradeShowGrid'
EXEC usp_AddCustom_ScreenObjects @ObjectName, 'List', 'PRCompanyTradeShow', 'N', 0, 'PRCompanyTradeShow';
EXEC usp_AddCustom_Lists @ObjectName, 10, 'prcts_TradeShow', '', 'Y'
EXEC usp_AddCustom_Lists @ObjectName, 20, 'prcts_Year', '', 'Y'
EXEC usp_AddCustom_Lists @ObjectName, 30, 'prcts_Booth', '', 'Y'

EXEC usp_DefineCaptions 'PRCompanyTradeShow', 'Trade Show', 'Trade Shows', NULL, NULL, NULL, NULL
Go


EXEC usp_AddCustom_Lists 'PRCompanyBrandGrid', '40', 'prc3_Sequence', '', 'Y'
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyBrand_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyBrand_ins]
GO


/* New Table - PRCompanyTradeAssociation */
EXEC usp_AccpacCreateTable @EntityName='PRCompanyTradeAssociation', @ColPrefix='prcta', @IDField='prcta_CompanyTradeAssociationID', @UseIdentityForKey='N'
EXEC usp_AccpacCreateKeyIdentityField  'PRCompanyTradeAssociation', 'prcta_CompanyTradeAssociationID', 'Company Trade Association ID';
EXEC usp_AccpacCreateSearchSelectField 'PRCompanyTradeAssociation', 'prcta_CompanyID', 'Company', 'Company', 50
EXEC usp_AccpacCreateSelectField       'PRCompanyTradeAssociation', 'prcta_TradeAssociationCode', 'Trade Association', 'prcta_TradeAssociationCode' 
EXEC usp_AccpacCreateTextField         'PRCompanyTradeAssociation', 'prcta_MemberID', 'Member ID', 25, 25;
EXEC usp_AccpacCreateCheckboxField     'PRCompanyTradeAssociation', 'prcta_Disabled', 'Disabled'


DECLARE @SQL VARCHAR(4000)
SET @SQL = 'ALTER TABLE PRCompanyTradeAssociation DROP CONSTRAINT |ConstraintName| '
SET @SQL = REPLACE(@SQL, '|ConstraintName|', ( SELECT name FROM sysobjects WHERE xtype = 'PK' AND parent_obj = OBJECT_ID('PRCompanyTradeAssociation')))
EXEC (@SQL)

ALTER TABLE [dbo].[PRCompanyTradeAssociation] ADD CONSTRAINT PK_PRCompanyTradeAssociation PRIMARY KEY NONCLUSTERED (prcta_CompanyTradeAssociationID)


DECLARE @ObjectName varchar(max), @EntityName varchar(max)
DECLARE @ScreenName varchar(max);

DECLARE @LN_New bit, @LN_Same bit, @RQ_Required bit, @RQ_NotRequired bit
SELECT @LN_New=1, @LN_Same=0, @RQ_Required=1, @RQ_NotRequired=0
SET @ObjectName = 'PRCompanyTradeAssociationGrid'
EXEC usp_AddCustom_ScreenObjects @ObjectName, 'List', 'PRCompanyTradeAssociation', 'N', 0, 'PRCompanyTradeAssociation';
EXEC usp_AddCustom_Lists @ObjectName, 10, 'prcta_TradeAssociationCode', '', 'Y', '', '', 'Custom', '', '', 'PRCompany/PRCompanyTradeAssociation.asp', 'prcta_CompanyTradeAssociationID'
EXEC usp_AddCustom_Lists @ObjectName, 20, 'prcta_MemberID', '', 'Y'
EXEC usp_AddCustom_Lists @ObjectName, 30, 'prcta_Disabled', '', 'Y'

EXEC usp_DefineCaptions 'PRCompanyTradeAssociation', 'Trade Association Membership', 'Trade Association Memberships', NULL, NULL, NULL, NULL

SET @ObjectName = 'PRCompanyTradeAssocNewEntry'
EXEC usp_DeleteCustom_ScreenObject @ObjectName
EXEC usp_AddCustom_ScreenObjects @ObjectName, 'Screen', 'PRCompanyTradeAssociation', 'N', 0, 'PRCompanyTradeAssociation'
EXEC usp_AddCustom_Screens @ObjectName, 10, 'prcta_TradeAssociationCode', @LN_New, 1, 1, @RQ_Required
EXEC usp_AddCustom_Screens @ObjectName, 20, 'prcta_MemberID', @LN_Same, 1, 1, @RQ_NotRequired
EXEC usp_AddCustom_Screens @ObjectName, 30, 'prcta_Disabled', @LN_Same, 1, 1, @RQ_NotRequired
Go

exec usp_AccpacGetBlockInfo 'PRCompanyTradeAssocNewEntry'


/* New Table - PRWidgetKey */
EXEC usp_AccpacCreateTable @EntityName='PRWidgetKey', @ColPrefix='prwk', @IDField='prwk_WidgetKeyID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyIdentityField  'PRWidgetKey', 'prwk_WidgetKeyID', 'Widget Key ID';
EXEC usp_AccpacCreateSearchSelectField 'PRWidgetKey', 'prwk_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateSelectField       'PRWidgetKey', 'prwk_WidgetTypeCode', 'Widget Type', 'prwk_WidgetTypeCode' 
EXEC usp_AccpacCreateTextField         'PRWidgetKey', 'prwk_LicenseKey', 'License Key', 50, 50;
EXEC usp_AccpacCreateTextField         'PRWidgetKey', 'prwk_HostName', 'Host Name', 50, 100;
EXEC usp_AccpacCreateIntegerField      'PRWidgetKey', 'prwk_AccessCount', 'Access Count', 10
EXEC usp_AccpacCreateDateTimeField     'PRWidgetKey', 'prwk_LastAccessDateTime', 'Last Access'
EXEC usp_AccpacCreateCheckboxField     'PRWidgetKey', 'prwk_Disabled', 'Disabled'
Go


EXEC usp_AccpacCreateDateTimeField     'Company', 'comp_PRLogoChangedDate', 'Logo Changed Date'
EXEC usp_AccpacCreateUserSelectField   'Company', 'comp_PRLogoChangedBy', 'Logo Changed By'

EXEC usp_AddCustom_Screens 'PRLogoSpotlight', 20, 'comp_PRLogoChangedDate', '1', '1', '1', null, null, null, null, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRLogoSpotlight', 30, 'comp_PRLogoChangedBy', '0', '1', '1', null, null, null, null, 'ReadOnly=true;'
Go

UPDATE WorkFlowRules
   SET wkrl_CustomFile = 'PROpportunity/PROpportunitySummary.asp'
 WHERE wkrl_CustomFile = 'PROpportunity/PRBlueprintsOpportunity.asp'
    OR wkrl_CustomFile = 'PROpportunity/PRMembershipOpportunity.asp'
    OR wkrl_CustomFile = 'PROpportunity/PRMembershipUpgradeOpp.asp';
Go    


UPDATE Custom_Lists
   SET GriP_OrderByDesc = 'Y',
       GriP_DefaultOrderBy = 'Y',
       GriP_Alignment = 'center'
 WHERE GriP_GridName = 'PRCompanyBrandGrid' 
   AND GriP_ColName = 'prc3_Sequence';
Go

EXEC usp_AccpacCreateCheckboxField     'PRAttentionLine', 'prattn_BBOSOnly', 'BBOS Only'
Go

/* New Table - PRPACALicenseMoveAuditLog */
EXEC usp_AccpacDropTable 'PRPACALicenseMoveAuditLog'
EXEC usp_AccpacCreateTable             'PRPACALicenseMoveAuditLog', 'prplmal', 'prplmal_PACALicenseMoveAuditLogID'
EXEC usp_AccpacCreateKeyField          'PRPACALicenseMoveAuditLog', 'prplmal_PACALicenseMoveAuditLogID', 'PACALicenseMoveAuditLog ID'
EXEC usp_AccpacCreateSearchSelectField 'PRPACALicenseMoveAuditLog', 'prplmal_SourceCompanyID', 'Source Company', 'Company', 50 
EXEC usp_AccpacCreateSearchSelectField 'PRPACALicenseMoveAuditLog', 'prplmal_TargetCompanyID', 'Target Company', 'Company', 50 
EXEC usp_AccpacCreateTextField         'PRPACALicenseMoveAuditLog', 'prplmal_LicenseNumber', 'License Number', 50, 50;
EXEC usp_AccpacCreateTextField         'PRPACALicenseMoveAuditLog', 'prplmal_Notes', 'Notes', 50, 500;

EXEC usp_DeleteCustom_ScreenObject 'PRPACALicenseMoveAuditLogNew'
EXEC usp_AddCustom_ScreenObjects 'PRPACALicenseMoveAuditLogNew', 'Screen', 'PRPACALicenseMoveAuditLog', 'N', 0, 'PRPACALicenseMoveAuditLog'
EXEC usp_AddCustom_Screens 'PRPACALicenseMoveAuditLogNew', 10, 'prplmal_SourceCompanyID', 1, 1, 1, 1
EXEC usp_AddCustom_Screens 'PRPACALicenseMoveAuditLogNew', 20, 'prplmal_TargetCompanyID', 0, 1, 1, 1
Go


EXEC usp_AccpacCreateIntegerField      'PRCommodity', 'prcm_PublicationArticleID', 'Publication Article'
Go

UPDATE custom_lists
   SET grip_order = grip_order * 10
 WHERE grip_gridname = 'CommunicationToDoList'

EXEC usp_AddCustom_Lists 'CommunicationToDoList', 45, 'CityStateCountryShort', '', 'Y'
Go


EXEC usp_AccpacCreateIntegerField 'PRWebUser', 'prwu_MemberMessageLoginCount', 'Member Message Login Count'
EXEC usp_AccpacCreateIntegerField 'PRWebUser', 'prwu_NonMemberMessageLoginCount', 'Non-Member Message Login Count'

EXEC usp_AccpacCreateDropdownValue 'MemberMessageCenterMsg', 'MaxLoginCount', 1, '0'
EXEC usp_AccpacCreateDropdownValue 'MemberMessageCenterMsg', 'Message', 1, ''

EXEC usp_AccpacCreateDropdownValue 'NonMemberMessageCenterMsg', 'MaxLoginCount', 1, '0'
EXEC usp_AccpacCreateDropdownValue 'NonMemberMessageCenterMsg', 'Message', 1, ''



Go