EXEC usp_AccpacCreateCheckboxField 'Company', 'comp_PROnlineOnly', 'Online Only'

EXEC usp_AddCustom_Screens 'PRCompanyInfo', 38, 'comp_PROnlineOnly', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 41, 'comp_PRUnconfirmed', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 62, 'comp_PRAccountTier', 0, 1, 1
Go

EXEC usp_AccpacGetBlockInfo 'PRShipmentLogQueue'

EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 23, 'Comp_CompanyId', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 26, 'comp_PRCorrTradestyle', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRShipmentLogQueue', 55, 'prshplg_CreatedBy', 0, 1, 1

EXEC usp_AddCustom_Lists 'PRShipmentLogQueueGrid', 25, 'prshplg_CreatedBy', null, 'Y'
EXEC usp_AddCustom_Lists 'PRShipmentLogQueueGrid', 33, 'Comp_CompanyId', null, 'Y', NULL, 'CENTER', 'Custom', 'NULL', 'NULL', 'PRCompany/PRCompanySummary.asp', 'Comp_CompanyId'
EXEC usp_AddCustom_Lists 'PRShipmentLogQueueGrid', 36, 'comp_PRCorrTradestyle', null, 'Y'


Go

EXEC usp_AddCustom_Screens 'PRFinancialHeader', 155, 'prfs_UpdatedBy', 0, 1, 1
Go

EXEC usp_AccpacCreateDateField 'PRSSFile', 'prss_ClaimantTradeReportDate', 'Trade Report Date'
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 675, 'prss_ClaimantTradeReportDate', 0, 1, 2
EXEC usp_AccpacCreateIntegerField 'PRTradeReport', 'prtr_SSFileID', 'SS File ID'
Go


EXEC usp_AddCustom_Screens 'PersonSearchBox', 20, 'pers_LastNameAlphaOnly',  1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonSearchBox', 30, 'pers_FirstNameAlphaOnly', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonSearchBox', 40, 'pers_PRNickname1',  0, 1, 1, 0

EXEC usp_AddCustom_Screens 'PersonSearchBox', 50, 'comp_PRIndustryType', 1, 1, 1

EXEC usp_DeleteCustom_List 'PersonGrid', 'Pers_PhoneFullNumber'
EXEC usp_DeleteCustom_List 'PersonGrid', 'pers_secterr'

EXEC usp_AddCustom_Lists 'PersonGrid', 200, 'comp_companyid', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonGrid', 210, 'Comp_Name', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonGrid', 220, 'CityStateCountryShort', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonGrid', 230, 'comp_PRIndustryType', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonGrid', 240, 'pers_PRNotes'

EXEC usp_AccpacCreateField @EntityName = 'Person', 
                           @FieldName = '_DeceasedSearch',
                           @Caption = 'Deceased',
                           @AccpacEntryType = 45,
                           @AccpacEntrySize = 0,
                           @DBFieldType = 'nchar',
                           @DBFieldSize = 1,
                           @AllowNull = 'Y',
                           @IsRequired = 'N', 
                           @AllowEdit = 'Y', 
                           @IsUnique = 'N',
                           @DefaultValue = NULL,    
			               @SkipColumnCreation = 'Y'


--EXEC usp_DeleteCustom_Screen 'PersonAdvancedSearchBox', 'email_EmailAddress'
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 10, 'pers_LastName', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 20, 'pers_FirstName', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 30, 'pers_PRNickname1',  0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 40, 'pers_PRMaidenName', 0, 1, 1, 0

EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 50, 'phon_AreaCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 60, 'phon_Number', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 70, 'prci_CityID', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 80, 'prst_StateID', 0, 1, 1, 0

EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 90, 'comp_PRIndustryType', 1, 1, 1
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 110, 'emai_EmailAddress', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 120, 'pers_PRUnconfirmed', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PersonAdvancedSearchBox', 130, '_DeceasedSearch', 0, 1, 1, 0



EXEC usp_DeleteCustom_List 'PersonAdvancedSearchGrid', 'pers_PRMaidenName'
EXEC usp_DeleteCustom_List 'PersonAdvancedSearchGrid', 'CompanyList'

EXEC usp_AddCustom_Lists 'PersonAdvancedSearchGrid', 60, 'pers_LastName', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonAdvancedSearchGrid', 70, 'pers_FirstName', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonAdvancedSearchGrid', 80, 'pers_EmailAddress', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonAdvancedSearchGrid', 200, 'comp_companyid', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonAdvancedSearchGrid', 210, 'Comp_Name', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonAdvancedSearchGrid', 220, 'CityStateCountryShort', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonAdvancedSearchGrid', 230, 'comp_PRIndustryType', null, 'Y'
EXEC usp_AddCustom_Lists 'PersonAdvancedSearchGrid', 240, 'pers_PRNotes'
Go



EXEC usp_DeleteCustom_Screen 'PRAdCampaignBilling', 'pradc_Discount'
EXEC usp_DeleteCustom_Screen 'PRAdCampaignBP', 'pradc_Discount'
Go



EXEC usp_AccpacCreateSelectField 'PRMembershipPurchase', 'prmp_HowLearned', 'How Learned', 'ProduceHowLearned'
EXEC usp_AccpacCreateTextField   'PRMembershipPurchase', 'prmp_HowLearnedOther', 'How Learned Other', 100, 100
EXEC usp_AccpacCreateTextField   'PRMembershipPurchase', 'prmp_ReferralPerson', 'Referral Person', 100, 100
EXEC usp_AccpacCreateTextField   'PRMembershipPurchase', 'prmp_ReferralCompany', 'Referral Company', 100, 200
Go

EXEC usp_AddCustom_Screens 'PRCompanyNew', 65, 'comp_PRLegalName', 0, 1, 1, 0
Go


EXEC usp_DeleteCustom_ScreenObject 'PRExternalNewsGrid'
EXEC usp_AddCustom_ScreenObjects 'PRExternalNewsGrid', 'List', 'vPRExternalNews', 'N', 0, 'vPRExternalNews'
EXEC usp_AddCustom_Lists 'PRExternalNewsGrid', 10, 'pren_SubjectCompanyID', null, 'Y'
EXEC usp_AddCustom_Lists 'PRExternalNewsGrid', 30, 'pren_PublishDateTime', null, 'Y', null, 'CENTER'
EXEC usp_AddCustom_Lists 'PRExternalNewsGrid', 40, 'pren_Name', null, 'Y', 'Y', '', 'Custom', '', '', 'PRGeneral/ExternalNewsArticle.asp', 'pren_ExternalNewsID'
EXEC usp_AddCustom_Lists 'PRExternalNewsGrid', 50, 'pren_PrimarySourceCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRExternalNewsGrid', 60, 'pren_SecondarySourceCode', null, 'Y'
EXEC usp_AddCustom_Lists 'PRExternalNewsGrid', 70, 'pren_SecondarySourceName', null, 'Y'



EXEC usp_DeleteCustom_ScreenObject 'PRExternalNewsSearchBox'
EXEC usp_AddCustom_ScreenObjects 'PRExternalNewsSearchBox', 'SearchScreen', 'PRExternalNews', 'N', 0, 'vPRExternalNews'
EXEC usp_AddCustom_Screens 'PRExternalNewsSearchBox', 10, 'pren_SubjectCompanyID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRExternalNewsSearchBox', 20, 'pren_PublishDateTime', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRExternalNewsSearchBox', 30, 'pren_PrimarySourceCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRExternalNewsSearchBox', 40, 'pren_SecondarySourceCode', 0, 1, 1, 0

EXEC usp_AddCustom_ScreenObjects 'ExternalNewsArticle', 'Screen', 'PRExternalNews', 'N', 0, 'PRExternalNews'
EXEC usp_AddCustom_Screens 'ExternalNewsArticle', 10, 'pren_SubjectCompanyID', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'ExternalNewsArticle', 20, 'pren_PublishDateTime', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'ExternalNewsArticle', 30, 'pren_Name', 1, 1, 2, 0
EXEC usp_AddCustom_Screens 'ExternalNewsArticle', 40, 'pren_PrimarySourceCode', 1, 1, 1, 0
EXEC usp_AddCustom_Screens 'ExternalNewsArticle', 50, 'pren_SecondarySourceCode', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'ExternalNewsArticle', 60, 'pren_SecondarySourceName', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'ExternalNewsArticle', 70, 'pren_Description', 1, 1, 3, 0
EXEC usp_AddCustom_Screens 'ExternalNewsArticle', 80, 'pren_URL', 1, 1, 3, 0


EXEC usp_AddCustom_Tabs 165, 'find', 'External News Articles', 'customfile', 'PRGeneral/ExternalNewsListing.asp'  

EXEC usp_AccpacCreateSelectField       'PRExternalNews', 'pren_PrimarySourceCode', 'Primary Source', 'pren_PrimarySourceCode'
Go


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'PRBBOSPrivilege')
BEGIN
	CREATE TABLE [dbo].[PRBBOSPrivilege](
		[BBOSPrivilegeID] [int] IDENTITY(1,1) NOT NULL,
		[IndustryType] [varchar](40) NOT NULL,
		[AccessLevel] [int] NOT NULL,
		[Privilege] [varchar](100) NOT NULL,
		[Role] [varchar](50) NULL,
		[Visible] bit NULL DEFAULT(0),
		[Enabled] bit NULL DEFAULT(0)
	 CONSTRAINT [PK_PRBBOSPrivilege] PRIMARY KEY CLUSTERED 
	(
		[BBOSPrivilegeID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO


EXEC usp_AccpacCreateSelectField 'PRCountry', 'prcn_Region', 'Region', 'prcn_Region'
Go

EXEC usp_AccpacCreateSelectField 'PRPACALicense', 'prpa_TerminateCode', 'Status Code', 'prpa_TerminateCode'
UPDATE Custom_Captions 
   SET capt_us = 'Anniversay Date',
       capt_uk = 'Anniversay Date',
       capt_fr = 'Anniversay Date',
       capt_de = 'Anniversay Date',
       capt_es = 'Anniversay Date'
WHERE capt_code = 'prpa_TerminateDate'
Go

EXEC usp_AccpacCreateCheckboxField 'Company', 'comp_PRExcludeAsEquifaxSubject', 'Exclude As Equifax Subject'
Go

