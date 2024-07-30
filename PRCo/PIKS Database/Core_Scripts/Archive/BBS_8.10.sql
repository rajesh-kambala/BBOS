--8.10 Release
USE CRM

UPDATE Custom_ScreenObjects SET cobj_CustomTableIDFK=100 WHERE cobj_targettable = 'vprlocation'
EXEC usp_TravantCRM_DropView 'vPRLocation'
EXEC usp_TravantCRM_DropView 'vPRCompanyLocation'

--TODO: Be sure to update it back to the vPRLocation table AFTER build runs -- a new ID will be generated
--TODO: update custom_screenobjects set cobj_customtableidfk=(select bord_tableid from Custom_Tables where bord_indexviewname='vprlocation' or bord_name='vprlocation') where cobj_targettable = 'vprlocation'

ALTER TABLE dbo.PRCity
ALTER COLUMN prci_TimezoneOffset DECIMAL(10,2) NULL
GO

--Defect 6878 
EXEC usp_TravantCRM_CreateDateTimeField 'PRAdCampaign', 'pradc_ExpirationEmailDate', 'Expiration Email Date', 'Y'
GO

--Defect 6792
EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRPhoneQuickAdd'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRPhoneQuickAdd', 'Screen', 'Phone', null, 0, 'vPhone'
EXEC usp_TravantCRM_AddCustom_Screens 'PRPhoneQuickAdd', 10, 'phon_CountryCode', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRPhoneQuickAdd', 20, 'phon_AreaCode', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRPhoneQuickAdd', 30, 'phon_Number', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRPhoneQuickAdd', 40, 'plink_Type', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PRPhoneQuickAdd', 50, 'phon_prpublish', 0, 1, 1, 0
GO

--Defect 6898
EXEC usp_TravantCRM_CreateCheckboxField     'PRAdCampaign', 'pradc_KYCMobileHomeDisplay', 'Display on KYC Mobile Home Page'

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'AdCampaignAdKYCDigital'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'AdCampaignAdKYCDigital', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 10, 'pradc_StartDate', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 20, 'pradc_EndDate', 0, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 30, 'pradc_CreativeStatus', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 40, 'pradc_TargetURL', 1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'AdCampaignAdKYCDigital', 50, 'pradc_KYCMobileHomeDisplay', 0, 1, 1, 0

--
-- Data Cleanup
EXEC usp_TravantCRM_DropTable 'PREquifaxAuditLog'
EXEC usp_TravantCRM_DropTable 'PREquifaxAuditLogDetail'
EXEC usp_TravantCRM_DropTable 'PREquifaxData'
EXEC usp_TravantCRM_DropTable 'PREquifaxDataTradeInfo'
EXEC usp_TravantCRM_DropTable 'PREBBConversion'
EXEC usp_TravantCRM_DropTable 'PREBBConversionDetail'
Go

--Defect 5681
--New PRCompanyNote table
EXEC usp_TravantCRM_DropTable 'PRCompanyNote'
EXEC usp_TravantCRM_CreateTable 'PRCompanyNote', 'prcomnot', 'prcomnot_CompanyNoteId'
EXEC usp_TravantCRM_CreateKeyField 'PRCompanyNote', 'prcomnot_CompanyId', 'Company Note Company Id' 
EXEC usp_TravantCRM_CreateTextField 'PRCompanyNote', 'prcomnot_CompanyNoteType', 'Company Note Type', 50
EXEC usp_TravantCRM_CreateMultilineField 'PRCompanyNote', 'prcomnot_CompanyNoteNote', 'Company Note Note', 150, 10
GO

EXEC usp_TravantCRM_DeleteCustom_ScreenObject 'PRCompanyNotes'
EXEC usp_TravantCRM_AddCustom_ScreenObjects 'PRCompanyNotes', 'Screen', 'PRCompanyNotes', 'N', 0, 'PRCompanyNotes'
EXEC usp_TravantCRM_AddCustom_Screens 'PRCompanyNotes', 10, 'prcomnot_CompanyNoteNote',      1, 1, 1, 0
Go

--Copy old notes to new table
DECLARE @RowCount int
DECLARE @Ndx int
DECLARE @CompanyId int
DECLARE @NoteType varchar(50)
DECLARE @NoteNote varchar(max)

DECLARE @FinancialNotes TABLE
(
	ID int identity(1,1) PRIMARY KEY,
	prcomnot_CompanyId int,
	prcomnot_CompanyNoteType varchar(50),
	prcomnot_CompanyNoteNote varchar(max)
)
INSERT INTO @FinancialNotes(prcomnot_CompanyId, prcomnot_CompanyNoteType, prcomnot_CompanyNoteNote )
	SELECT comp_companyid, 'FINANCIAL', comp_PRFinancialNotes FROM Company where ISNULL(comp_PRFinancialNotes,'') <> ''

SET @RowCount = @@ROWCOUNT
SET @Ndx = 0
WHILE (@Ndx < @RowCount) BEGIN
	SET @Ndx = @Ndx + 1
    -- Go get the next TES Company
    SELECT	@CompanyID = prcomnot_CompanyId,
			@NoteType=prcomnot_CompanyNoteType,
			@NoteNote=prcomnot_CompanyNoteNote
    FROM @FinancialNotes
 	WHERE ID = @Ndx;

	DECLARE @NextID int
	EXEC usp_GetNextId 'PRCompanyNote', @NextID output
	INSERT INTO PRCompanyNote (prcomnot_CompanyNoteId, prcomnot_CreatedBy, prcomnot_CreatedDate, prcomnot_UpdatedBy, prcomnot_UpdatedDate, prcomnot_CompanyId, prcomnot_CompanyNoteType, prcomnot_CompanyNoteNote)
		VALUES (@NextID, -1, GETDATE(), -1, GETDATE(), @CompanyId, @NoteType, @NoteNote)
END
GO

DECLARE @RowCount int
DECLARE @Ndx int
DECLARE @CompanyId int
DECLARE @NoteType varchar(50)
DECLARE @NoteNote varchar(max)

DECLARE @TradeActivityNotes TABLE
(
	ID int identity(1,1) PRIMARY KEY,
	prcomnot_CompanyId int,
	prcomnot_CompanyNoteType varchar(50),
	prcomnot_CompanyNoteNote varchar(max)
)
INSERT INTO @TradeActivityNotes(prcomnot_CompanyId, prcomnot_CompanyNoteType, prcomnot_CompanyNoteNote )
	SELECT comp_companyid, 'TRADEACTIVITY', comp_PRTradeActivityNotes FROM Company where ISNULL(comp_PRTradeActivityNotes,'') <> ''

SET @RowCount = @@ROWCOUNT
SET @Ndx = 0
WHILE (@Ndx < @RowCount) BEGIN
	SET @Ndx = @Ndx + 1
    -- Go get the next TES Company
    SELECT	@CompanyID = prcomnot_CompanyId,
			@NoteType=prcomnot_CompanyNoteType,
			@NoteNote=prcomnot_CompanyNoteNote
    FROM @TradeActivityNotes
 	WHERE ID = @Ndx;

	DECLARE @NextID int
	EXEC usp_GetNextId 'PRCompanyNote', @NextID output
	INSERT INTO PRCompanyNote (prcomnot_CompanyNoteId, prcomnot_CreatedBy, prcomnot_CreatedDate, prcomnot_UpdatedBy, prcomnot_UpdatedDate, prcomnot_CompanyId, prcomnot_CompanyNoteType, prcomnot_CompanyNoteNote)
		VALUES (@NextID, -1, GETDATE(), -1, GETDATE(), @CompanyId, @NoteType, @NoteNote)
END
GO

--TODO:JMT Drop comp_PRFinancialNotes field
--TODO:JMT Drop comp_PRTradeActivityNotes field

--Defect 4576 for prcl2_PersonID
UPDATE custom_edits SET colp_SearchSQL='pers_PRUnconfirmed IS NULL AND peli_PRStatus=''1''' WHERE colp_colpropsid=14871

--Defect 6981 for PROpportunitySummary.asp
EXEC usp_TravantCRM_AddCustom_Screens 'PROpportunitySummary', 260, 'oppo_PRLostReason',  1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PROpportunitySummary', 280, 'oppo_Note',  1, 1, 3, 0

