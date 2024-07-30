/* ************************************************************
 * Name:   dbo.trg_Company_ioupd
 * 
 * Table:  Company
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Company_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Company_ioupd]
GO

CREATE TRIGGER dbo.trg_Company_ioupd
ON Company
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @Comp_CompanyId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.comp_CompanyID, @UserId = i.Comp_UpdatedBy, @Comp_CompanyId = i.Comp_CompanyId
        FROM Inserted i
        INNER JOIN deleted d ON i.Comp_CompanyId = d.Comp_CompanyId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (Comp_Name) OR
        Update (Comp_Type) OR
        Update (Comp_Status) OR
        Update (Comp_Source) OR
        Update (Comp_Territory) OR
        Update (Comp_Revenue) OR
        Update (Comp_Employees) OR
        Update (Comp_Sector) OR
        Update (Comp_IndCode) OR
        Update (Comp_MailRestriction) OR
        Update (Comp_Deleted) OR
        Update (comp_PRHQId) OR
        Update (comp_PRCorrTradestyle) OR
        Update (comp_PRBookTradestyle) OR
        Update (comp_PRSubordinationAgrProvided) OR
        Update (comp_PRSubordinationAgrDate) OR
        Update (comp_PRExcludeFSRequest) OR
        Update (comp_PRSpecialInstruction) OR
        Update (comp_PRDataQualityTier) OR
        Update (comp_PRListingCityId) OR
        Update (comp_PRListingStatus) OR
        Update (comp_PRAccountTier) OR
        Update (comp_PRBusinessStatus) OR
        Update (comp_PRTradestyle1) OR
        Update (comp_PRTradestyle2) OR
        Update (comp_PRTradestyle3) OR
        Update (comp_PRTradestyle4) OR
        Update (comp_PRLegalName) OR
        Update (comp_PROriginalName) OR
        Update (comp_PROldName1) OR
        Update (comp_PROldName1Date) OR
        Update (comp_PROldName2) OR
        Update (comp_PROldName2Date) OR
        Update (comp_PROldName3) OR
        Update (comp_PROldName3Date) OR
        Update (comp_PRType) OR
        Update (comp_PRPublishUnloadHours) OR
        Update (comp_PRPublishDL) OR
        Update (comp_PRMoralResponsibility) OR
        Update (comp_PRSpecialHandlingInstruction) OR
        Update (comp_PRHandlesInvoicing) OR
        Update (comp_PRReceiveLRL) OR
        Update (comp_PRTMFMAward) OR
        Update (comp_PRTMFMAwardDate) OR
        Update (comp_PRTMFMCandidate) OR
        Update (comp_PRTMFMCandidateDate) OR
        Update (comp_PRAdministrativeUsage) OR
        Update (comp_PRReceiveTES) OR
        Update (comp_PRCreditWorthCap) OR
        Update (comp_PRCreditWorthCapReason) OR
        Update (comp_PRConfidentialFS) OR
        Update (comp_PRUnattributedOwnerPct) OR
        Update (comp_PRUnattributedOwnerDesc) OR
        Update (comp_PRBusinessReport) OR
        Update (comp_PRPrincipalsBackgroundText) OR
        Update (comp_PRWebActivated) OR
        Update (comp_PRWebActivatedDate) OR
        Update (comp_PRServicesThroughCompanyId) OR
        Update (comp_PRIndustryType) OR
        Update (comp_PRReceivesBBScoreReport) OR
        Update (comp_PRUnconfirmed) OR
        Update (comp_PRPublishPayIndicator) OR
        Update (comp_PROnlineOnly) OR
        Update (comp_PRARReportAccess) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company ' + convert(varchar,@Comp_CompanyId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_Comp_Name nchar(60), @del_Comp_Name nchar(60)
        Declare @ins_Comp_Type nchar(40), @del_Comp_Type nchar(40)
        Declare @ins_Comp_Status nchar(40), @del_Comp_Status nchar(40)
        Declare @ins_Comp_Source nchar(40), @del_Comp_Source nchar(40)
        Declare @ins_Comp_Territory nchar(40), @del_Comp_Territory nchar(40)
        Declare @ins_Comp_Revenue nchar(40), @del_Comp_Revenue nchar(40)
        Declare @ins_Comp_Employees nchar(40), @del_Comp_Employees nchar(40)
        Declare @ins_Comp_Sector nchar(40), @del_Comp_Sector nchar(40)
        Declare @ins_Comp_IndCode nchar(40), @del_Comp_IndCode nchar(40)
        Declare @ins_Comp_MailRestriction nchar(40), @del_Comp_MailRestriction nchar(40)
        Declare @ins_Comp_Deleted tinyint, @del_Comp_Deleted tinyint
        Declare @ins_comp_PRHQId int, @del_comp_PRHQId int
        Declare @ins_comp_PRCorrTradestyle nvarchar(104), @del_comp_PRCorrTradestyle nvarchar(104)
        Declare @ins_comp_PRBookTradestyle nvarchar(104), @del_comp_PRBookTradestyle nvarchar(104)
        Declare @ins_comp_PRSubordinationAgrProvided nchar(1), @del_comp_PRSubordinationAgrProvided nchar(1)
        Declare @ins_comp_PRSubordinationAgrDate datetime, @del_comp_PRSubordinationAgrDate datetime
        Declare @ins_comp_PRExcludeFSRequest nchar(1), @del_comp_PRExcludeFSRequest nchar(1)
        Declare @ins_comp_PRSpecialInstruction varchar(max), @del_comp_PRSpecialInstruction varchar(max)
        Declare @ins_comp_PRDataQualityTier nvarchar(40), @del_comp_PRDataQualityTier nvarchar(40)
        Declare @ins_comp_PRListingCityId int, @del_comp_PRListingCityId int
        Declare @ins_comp_PRListingStatus nvarchar(40), @del_comp_PRListingStatus nvarchar(40)
        Declare @ins_comp_PRAccountTier nvarchar(40), @del_comp_PRAccountTier nvarchar(40)
        Declare @ins_comp_PRBusinessStatus nvarchar(40), @del_comp_PRBusinessStatus nvarchar(40)
        Declare @ins_comp_PRTradestyle1 nvarchar(104), @del_comp_PRTradestyle1 nvarchar(104)
        Declare @ins_comp_PRTradestyle2 nvarchar(104), @del_comp_PRTradestyle2 nvarchar(104)
        Declare @ins_comp_PRTradestyle3 nvarchar(104), @del_comp_PRTradestyle3 nvarchar(104)
        Declare @ins_comp_PRTradestyle4 nvarchar(104), @del_comp_PRTradestyle4 nvarchar(104)
        Declare @ins_comp_PRLegalName nvarchar(50), @del_comp_PRLegalName nvarchar(50)
        Declare @ins_comp_PROriginalName nvarchar(50), @del_comp_PROriginalName nvarchar(50)
        Declare @ins_comp_PROldName1 nvarchar(50), @del_comp_PROldName1 nvarchar(50)
        Declare @ins_comp_PROldName1Date datetime, @del_comp_PROldName1Date datetime
        Declare @ins_comp_PROldName2 nvarchar(50), @del_comp_PROldName2 nvarchar(50)
        Declare @ins_comp_PROldName2Date datetime, @del_comp_PROldName2Date datetime
        Declare @ins_comp_PROldName3 nvarchar(50), @del_comp_PROldName3 nvarchar(50)
        Declare @ins_comp_PROldName3Date datetime, @del_comp_PROldName3Date datetime
        Declare @ins_comp_PRType nvarchar(40), @del_comp_PRType nvarchar(40)
        Declare @ins_comp_PRPublishUnloadHours nchar(1), @del_comp_PRPublishUnloadHours nchar(1)
        Declare @ins_comp_PRPublishDL nchar(1), @del_comp_PRPublishDL nchar(1)
        Declare @ins_comp_PRMoralResponsibility nvarchar(10), @del_comp_PRMoralResponsibility nvarchar(10)
        Declare @ins_comp_PRSpecialHandlingInstruction varchar(max), @del_comp_PRSpecialHandlingInstruction varchar(max)
        Declare @ins_comp_PRHandlesInvoicing nchar(1), @del_comp_PRHandlesInvoicing nchar(1)
        Declare @ins_comp_PRReceiveLRL nchar(1), @del_comp_PRReceiveLRL nchar(1)
        Declare @ins_comp_PRTMFMAward nchar(1), @del_comp_PRTMFMAward nchar(1)
        Declare @ins_comp_PRTMFMAwardDate datetime, @del_comp_PRTMFMAwardDate datetime
        Declare @ins_comp_PRTMFMCandidate nchar(1), @del_comp_PRTMFMCandidate nchar(1)
        Declare @ins_comp_PRTMFMCandidateDate datetime, @del_comp_PRTMFMCandidateDate datetime
        Declare @ins_comp_PRAdministrativeUsage nvarchar(100), @del_comp_PRAdministrativeUsage nvarchar(100)
        Declare @ins_comp_PRReceiveTES nchar(1), @del_comp_PRReceiveTES nchar(1)
        Declare @ins_comp_PRCreditWorthCap int, @del_comp_PRCreditWorthCap int
        Declare @ins_comp_PRCreditWorthCapReason varchar(max), @del_comp_PRCreditWorthCapReason varchar(max)
        Declare @ins_comp_PRConfidentialFS nvarchar(40), @del_comp_PRConfidentialFS nvarchar(40)
        Declare @ins_comp_PRUnattributedOwnerPct int, @del_comp_PRUnattributedOwnerPct int
        Declare @ins_comp_PRUnattributedOwnerDesc varchar(max), @del_comp_PRUnattributedOwnerDesc varchar(max)
        Declare @ins_comp_PRBusinessReport nchar(1), @del_comp_PRBusinessReport nchar(1)
        Declare @ins_comp_PRPrincipalsBackgroundText varchar(max), @del_comp_PRPrincipalsBackgroundText varchar(max)
        Declare @ins_comp_PRWebActivated nchar(1), @del_comp_PRWebActivated nchar(1)
        Declare @ins_comp_PRWebActivatedDate datetime, @del_comp_PRWebActivatedDate datetime
        Declare @ins_comp_PRServicesThroughCompanyId int, @del_comp_PRServicesThroughCompanyId int
        Declare @ins_comp_PRIndustryType nvarchar(40), @del_comp_PRIndustryType nvarchar(40)
        Declare @ins_comp_PRReceivesBBScoreReport nchar(1), @del_comp_PRReceivesBBScoreReport nchar(1)
        Declare @ins_comp_PRUnconfirmed nchar(1), @del_comp_PRUnconfirmed nchar(1)
        Declare @ins_comp_PRPublishPayIndicator nchar(1), @del_comp_PRPublishPayIndicator nchar(1)
        Declare @ins_comp_PROnlineOnly nchar(1), @del_comp_PROnlineOnly nchar(1)
        Declare @ins_comp_PRARReportAccess nchar(1), @del_comp_PRARReportAccess nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_Comp_Name = i.Comp_Name, @del_Comp_Name = d.Comp_Name,
            @ins_Comp_Type = i.Comp_Type, @del_Comp_Type = d.Comp_Type,
            @ins_Comp_Status = i.Comp_Status, @del_Comp_Status = d.Comp_Status,
            @ins_Comp_Source = i.Comp_Source, @del_Comp_Source = d.Comp_Source,
            @ins_Comp_Territory = i.Comp_Territory, @del_Comp_Territory = d.Comp_Territory,
            @ins_Comp_Revenue = i.Comp_Revenue, @del_Comp_Revenue = d.Comp_Revenue,
            @ins_Comp_Employees = i.Comp_Employees, @del_Comp_Employees = d.Comp_Employees,
            @ins_Comp_Sector = i.Comp_Sector, @del_Comp_Sector = d.Comp_Sector,
            @ins_Comp_IndCode = i.Comp_IndCode, @del_Comp_IndCode = d.Comp_IndCode,
            @ins_Comp_MailRestriction = i.Comp_MailRestriction, @del_Comp_MailRestriction = d.Comp_MailRestriction,
            @ins_Comp_Deleted = i.Comp_Deleted, @del_Comp_Deleted = d.Comp_Deleted,
            @ins_comp_PRHQId = i.comp_PRHQId, @del_comp_PRHQId = d.comp_PRHQId,
            @ins_comp_PRCorrTradestyle = i.comp_PRCorrTradestyle, @del_comp_PRCorrTradestyle = d.comp_PRCorrTradestyle,
            @ins_comp_PRBookTradestyle = i.comp_PRBookTradestyle, @del_comp_PRBookTradestyle = d.comp_PRBookTradestyle,
            @ins_comp_PRSubordinationAgrProvided = i.comp_PRSubordinationAgrProvided, @del_comp_PRSubordinationAgrProvided = d.comp_PRSubordinationAgrProvided,
            @ins_comp_PRSubordinationAgrDate = i.comp_PRSubordinationAgrDate, @del_comp_PRSubordinationAgrDate = d.comp_PRSubordinationAgrDate,
            @ins_comp_PRExcludeFSRequest = i.comp_PRExcludeFSRequest, @del_comp_PRExcludeFSRequest = d.comp_PRExcludeFSRequest,
            @ins_comp_PRSpecialInstruction = i.comp_PRSpecialInstruction, @del_comp_PRSpecialInstruction = d.comp_PRSpecialInstruction,
            @ins_comp_PRDataQualityTier = i.comp_PRDataQualityTier, @del_comp_PRDataQualityTier = d.comp_PRDataQualityTier,
            @ins_comp_PRListingCityId = i.comp_PRListingCityId, @del_comp_PRListingCityId = d.comp_PRListingCityId,
            @ins_comp_PRListingStatus = i.comp_PRListingStatus, @del_comp_PRListingStatus = d.comp_PRListingStatus,
            @ins_comp_PRAccountTier = i.comp_PRAccountTier, @del_comp_PRAccountTier = d.comp_PRAccountTier,
            @ins_comp_PRBusinessStatus = i.comp_PRBusinessStatus, @del_comp_PRBusinessStatus = d.comp_PRBusinessStatus,
            @ins_comp_PRTradestyle1 = i.comp_PRTradestyle1, @del_comp_PRTradestyle1 = d.comp_PRTradestyle1,
            @ins_comp_PRTradestyle2 = i.comp_PRTradestyle2, @del_comp_PRTradestyle2 = d.comp_PRTradestyle2,
            @ins_comp_PRTradestyle3 = i.comp_PRTradestyle3, @del_comp_PRTradestyle3 = d.comp_PRTradestyle3,
            @ins_comp_PRTradestyle4 = i.comp_PRTradestyle4, @del_comp_PRTradestyle4 = d.comp_PRTradestyle4,
            @ins_comp_PRLegalName = i.comp_PRLegalName, @del_comp_PRLegalName = d.comp_PRLegalName,
            @ins_comp_PROriginalName = i.comp_PROriginalName, @del_comp_PROriginalName = d.comp_PROriginalName,
            @ins_comp_PROldName1 = i.comp_PROldName1, @del_comp_PROldName1 = d.comp_PROldName1,
            @ins_comp_PROldName1Date = i.comp_PROldName1Date, @del_comp_PROldName1Date = d.comp_PROldName1Date,
            @ins_comp_PROldName2 = i.comp_PROldName2, @del_comp_PROldName2 = d.comp_PROldName2,
            @ins_comp_PROldName2Date = i.comp_PROldName2Date, @del_comp_PROldName2Date = d.comp_PROldName2Date,
            @ins_comp_PROldName3 = i.comp_PROldName3, @del_comp_PROldName3 = d.comp_PROldName3,
            @ins_comp_PROldName3Date = i.comp_PROldName3Date, @del_comp_PROldName3Date = d.comp_PROldName3Date,
            @ins_comp_PRType = i.comp_PRType, @del_comp_PRType = d.comp_PRType,
            @ins_comp_PRPublishUnloadHours = i.comp_PRPublishUnloadHours, @del_comp_PRPublishUnloadHours = d.comp_PRPublishUnloadHours,
            @ins_comp_PRPublishDL = i.comp_PRPublishDL, @del_comp_PRPublishDL = d.comp_PRPublishDL,
            @ins_comp_PRMoralResponsibility = i.comp_PRMoralResponsibility, @del_comp_PRMoralResponsibility = d.comp_PRMoralResponsibility,
            @ins_comp_PRSpecialHandlingInstruction = i.comp_PRSpecialHandlingInstruction, @del_comp_PRSpecialHandlingInstruction = d.comp_PRSpecialHandlingInstruction,
            @ins_comp_PRHandlesInvoicing = i.comp_PRHandlesInvoicing, @del_comp_PRHandlesInvoicing = d.comp_PRHandlesInvoicing,
            @ins_comp_PRReceiveLRL = i.comp_PRReceiveLRL, @del_comp_PRReceiveLRL = d.comp_PRReceiveLRL,
            @ins_comp_PRTMFMAward = i.comp_PRTMFMAward, @del_comp_PRTMFMAward = d.comp_PRTMFMAward,
            @ins_comp_PRTMFMAwardDate = i.comp_PRTMFMAwardDate, @del_comp_PRTMFMAwardDate = d.comp_PRTMFMAwardDate,
            @ins_comp_PRTMFMCandidate = i.comp_PRTMFMCandidate, @del_comp_PRTMFMCandidate = d.comp_PRTMFMCandidate,
            @ins_comp_PRTMFMCandidateDate = i.comp_PRTMFMCandidateDate, @del_comp_PRTMFMCandidateDate = d.comp_PRTMFMCandidateDate,
            @ins_comp_PRAdministrativeUsage = i.comp_PRAdministrativeUsage, @del_comp_PRAdministrativeUsage = d.comp_PRAdministrativeUsage,
            @ins_comp_PRReceiveTES = i.comp_PRReceiveTES, @del_comp_PRReceiveTES = d.comp_PRReceiveTES,
            @ins_comp_PRCreditWorthCap = i.comp_PRCreditWorthCap, @del_comp_PRCreditWorthCap = d.comp_PRCreditWorthCap,
            @ins_comp_PRCreditWorthCapReason = i.comp_PRCreditWorthCapReason, @del_comp_PRCreditWorthCapReason = d.comp_PRCreditWorthCapReason,
            @ins_comp_PRConfidentialFS = i.comp_PRConfidentialFS, @del_comp_PRConfidentialFS = d.comp_PRConfidentialFS,
            @ins_comp_PRUnattributedOwnerPct = i.comp_PRUnattributedOwnerPct, @del_comp_PRUnattributedOwnerPct = d.comp_PRUnattributedOwnerPct,
            @ins_comp_PRUnattributedOwnerDesc = i.comp_PRUnattributedOwnerDesc, @del_comp_PRUnattributedOwnerDesc = d.comp_PRUnattributedOwnerDesc,
            @ins_comp_PRBusinessReport = i.comp_PRBusinessReport, @del_comp_PRBusinessReport = d.comp_PRBusinessReport,
            @ins_comp_PRPrincipalsBackgroundText = i.comp_PRPrincipalsBackgroundText, @del_comp_PRPrincipalsBackgroundText = d.comp_PRPrincipalsBackgroundText,
            @ins_comp_PRWebActivated = i.comp_PRWebActivated, @del_comp_PRWebActivated = d.comp_PRWebActivated,
            @ins_comp_PRWebActivatedDate = i.comp_PRWebActivatedDate, @del_comp_PRWebActivatedDate = d.comp_PRWebActivatedDate,
            @ins_comp_PRServicesThroughCompanyId = i.comp_PRServicesThroughCompanyId, @del_comp_PRServicesThroughCompanyId = d.comp_PRServicesThroughCompanyId,
            @ins_comp_PRIndustryType = i.comp_PRIndustryType, @del_comp_PRIndustryType = d.comp_PRIndustryType,
            @ins_comp_PRReceivesBBScoreReport = i.comp_PRReceivesBBScoreReport, @del_comp_PRReceivesBBScoreReport = d.comp_PRReceivesBBScoreReport,
            @ins_comp_PRUnconfirmed = i.comp_PRUnconfirmed, @del_comp_PRUnconfirmed = d.comp_PRUnconfirmed,
            @ins_comp_PRPublishPayIndicator = i.comp_PRPublishPayIndicator, @del_comp_PRPublishPayIndicator = d.comp_PRPublishPayIndicator,
            @ins_comp_PROnlineOnly = i.comp_PROnlineOnly, @del_comp_PROnlineOnly = d.comp_PROnlineOnly,
            @ins_comp_PRARReportAccess = i.comp_PRARReportAccess, @del_comp_PRARReportAccess = d.comp_PRARReportAccess
        FROM Inserted i
        INNER JOIN deleted d ON i.Comp_CompanyId = d.Comp_CompanyId

        -- Comp_Name
        IF  (  Update(Comp_Name))
        BEGIN
            SET @OldValue =  @del_Comp_Name
            SET @NewValue =  @ins_Comp_Name
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Name', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_Type
        IF  (  Update(Comp_Type))
        BEGIN
            SET @OldValue =  @del_Comp_Type
            SET @NewValue =  @ins_Comp_Type
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Type', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_Status
        IF  (  Update(Comp_Status))
        BEGIN
            SET @OldValue =  @del_Comp_Status
            SET @NewValue =  @ins_Comp_Status
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Status', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_Source
        IF  (  Update(Comp_Source))
        BEGIN
            SET @OldValue =  @del_Comp_Source
            SET @NewValue =  @ins_Comp_Source
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Source', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_Territory
        IF  (  Update(Comp_Territory))
        BEGIN
            SET @OldValue =  @del_Comp_Territory
            SET @NewValue =  @ins_Comp_Territory
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Territory', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_Revenue
        IF  (  Update(Comp_Revenue))
        BEGIN
            SET @OldValue =  @del_Comp_Revenue
            SET @NewValue =  @ins_Comp_Revenue
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Revenue', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_Employees
        IF  (  Update(Comp_Employees))
        BEGIN
            SET @OldValue =  @del_Comp_Employees
            SET @NewValue =  @ins_Comp_Employees
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Employees', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_Sector
        IF  (  Update(Comp_Sector))
        BEGIN
            SET @OldValue =  @del_Comp_Sector
            SET @NewValue =  @ins_Comp_Sector
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Sector', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_IndCode
        IF  (  Update(Comp_IndCode))
        BEGIN
            SET @OldValue =  @del_Comp_IndCode
            SET @NewValue =  @ins_Comp_IndCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_IndCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_MailRestriction
        IF  (  Update(Comp_MailRestriction))
        BEGIN
            SET @OldValue =  @del_Comp_MailRestriction
            SET @NewValue =  @ins_Comp_MailRestriction
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_MailRestriction', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_Deleted
        IF  (  Update(Comp_Deleted))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_Comp_Deleted)
            SET @NewValue =  convert(varchar(max), @ins_Comp_Deleted)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Deleted', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRHQId
        IF  (  Update(comp_PRHQId))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_comp_PRHQId)
            SET @NewValue =  convert(varchar(max), @ins_comp_PRHQId)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRHQId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRCorrTradestyle
        IF  (  Update(comp_PRCorrTradestyle))
        BEGIN
            SET @OldValue =  @del_comp_PRCorrTradestyle
            SET @NewValue =  @ins_comp_PRCorrTradestyle
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRCorrTradestyle', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRBookTradestyle
        IF  (  Update(comp_PRBookTradestyle))
        BEGIN
            SET @OldValue =  @del_comp_PRBookTradestyle
            SET @NewValue =  @ins_comp_PRBookTradestyle
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRBookTradestyle', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRSubordinationAgrProvided
        IF  (  Update(comp_PRSubordinationAgrProvided))
        BEGIN
            SET @OldValue =  @del_comp_PRSubordinationAgrProvided
            SET @NewValue =  @ins_comp_PRSubordinationAgrProvided
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRSubordinationAgrProvided', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRSubordinationAgrDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_comp_PRSubordinationAgrDate, @ins_comp_PRSubordinationAgrDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_comp_PRSubordinationAgrDate IS NOT NULL AND convert(varchar,@del_comp_PRSubordinationAgrDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_comp_PRSubordinationAgrDate)
            IF (@ins_comp_PRSubordinationAgrDate IS NOT NULL AND convert(varchar,@ins_comp_PRSubordinationAgrDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_comp_PRSubordinationAgrDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRSubordinationAgrDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRExcludeFSRequest
        IF  (  Update(comp_PRExcludeFSRequest))
        BEGIN
            SET @OldValue =  @del_comp_PRExcludeFSRequest
            SET @NewValue =  @ins_comp_PRExcludeFSRequest
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRExcludeFSRequest', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRSpecialInstruction
        IF  (  Update(comp_PRSpecialInstruction))
        BEGIN
            SET @OldValue =  @del_comp_PRSpecialInstruction
            SET @NewValue =  @ins_comp_PRSpecialInstruction
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRSpecialInstruction', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRDataQualityTier
        IF  (  Update(comp_PRDataQualityTier))
        BEGIN
            SET @OldValue =  @del_comp_PRDataQualityTier
            SET @NewValue =  @ins_comp_PRDataQualityTier
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRDataQualityTier', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRListingCityId
        IF  (  Update(comp_PRListingCityId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = CityStateCountryShort FROM vPRLocation WITH (NOLOCK) 
                WHERE prci_CityID = @ins_comp_PRListingCityId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_comp_PRListingCityId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = CityStateCountryShort FROM vPRLocation WITH (NOLOCK) 
                WHERE prci_CityID = @del_comp_PRListingCityId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_comp_PRListingCityId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRListingCityId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRListingStatus
        IF  (  Update(comp_PRListingStatus))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='comp_PRListingStatus' AND capt_code = @ins_comp_PRListingStatus
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_comp_PRListingStatus)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='comp_PRListingStatus' AND capt_code = @del_comp_PRListingStatus
            SET @OldValue = COALESCE(@NewValueTemp,  @del_comp_PRListingStatus)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRListingStatus', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRAccountTier
        IF  (  Update(comp_PRAccountTier))
        BEGIN
            SET @OldValue =  @del_comp_PRAccountTier
            SET @NewValue =  @ins_comp_PRAccountTier
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRAccountTier', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRBusinessStatus
        IF  (  Update(comp_PRBusinessStatus))
        BEGIN
            SET @OldValue =  @del_comp_PRBusinessStatus
            SET @NewValue =  @ins_comp_PRBusinessStatus
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRBusinessStatus', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRTradestyle1
        IF  (  Update(comp_PRTradestyle1))
        BEGIN
            SET @OldValue =  @del_comp_PRTradestyle1
            SET @NewValue =  @ins_comp_PRTradestyle1
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRTradestyle1', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRTradestyle2
        IF  (  Update(comp_PRTradestyle2))
        BEGIN
            SET @OldValue =  @del_comp_PRTradestyle2
            SET @NewValue =  @ins_comp_PRTradestyle2
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRTradestyle2', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRTradestyle3
        IF  (  Update(comp_PRTradestyle3))
        BEGIN
            SET @OldValue =  @del_comp_PRTradestyle3
            SET @NewValue =  @ins_comp_PRTradestyle3
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRTradestyle3', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRTradestyle4
        IF  (  Update(comp_PRTradestyle4))
        BEGIN
            SET @OldValue =  @del_comp_PRTradestyle4
            SET @NewValue =  @ins_comp_PRTradestyle4
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRTradestyle4', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRLegalName
        IF  (  Update(comp_PRLegalName))
        BEGIN
            SET @OldValue =  @del_comp_PRLegalName
            SET @NewValue =  @ins_comp_PRLegalName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRLegalName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PROriginalName
        IF  (  Update(comp_PROriginalName))
        BEGIN
            SET @OldValue =  @del_comp_PROriginalName
            SET @NewValue =  @ins_comp_PROriginalName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PROriginalName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PROldName1
        IF  (  Update(comp_PROldName1))
        BEGIN
            SET @OldValue =  @del_comp_PROldName1
            SET @NewValue =  @ins_comp_PROldName1
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PROldName1', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PROldName1Date
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_comp_PROldName1Date, @ins_comp_PROldName1Date) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_comp_PROldName1Date IS NOT NULL AND convert(varchar,@del_comp_PROldName1Date,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_comp_PROldName1Date)
            IF (@ins_comp_PROldName1Date IS NOT NULL AND convert(varchar,@ins_comp_PROldName1Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_comp_PROldName1Date)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PROldName1Date', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PROldName2
        IF  (  Update(comp_PROldName2))
        BEGIN
            SET @OldValue =  @del_comp_PROldName2
            SET @NewValue =  @ins_comp_PROldName2
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PROldName2', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PROldName2Date
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_comp_PROldName2Date, @ins_comp_PROldName2Date) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_comp_PROldName2Date IS NOT NULL AND convert(varchar,@del_comp_PROldName2Date,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_comp_PROldName2Date)
            IF (@ins_comp_PROldName2Date IS NOT NULL AND convert(varchar,@ins_comp_PROldName2Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_comp_PROldName2Date)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PROldName2Date', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PROldName3
        IF  (  Update(comp_PROldName3))
        BEGIN
            SET @OldValue =  @del_comp_PROldName3
            SET @NewValue =  @ins_comp_PROldName3
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PROldName3', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PROldName3Date
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_comp_PROldName3Date, @ins_comp_PROldName3Date) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_comp_PROldName3Date IS NOT NULL AND convert(varchar,@del_comp_PROldName3Date,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_comp_PROldName3Date)
            IF (@ins_comp_PROldName3Date IS NOT NULL AND convert(varchar,@ins_comp_PROldName3Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_comp_PROldName3Date)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PROldName3Date', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRType
        IF  (  Update(comp_PRType))
        BEGIN
            SET @OldValue =  @del_comp_PRType
            SET @NewValue =  @ins_comp_PRType
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRType', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRPublishUnloadHours
        IF  (  Update(comp_PRPublishUnloadHours))
        BEGIN
            SET @OldValue =  @del_comp_PRPublishUnloadHours
            SET @NewValue =  @ins_comp_PRPublishUnloadHours
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRPublishUnloadHours', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRPublishDL
        IF  (  Update(comp_PRPublishDL))
        BEGIN
            SET @OldValue =  @del_comp_PRPublishDL
            SET @NewValue =  @ins_comp_PRPublishDL
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRPublishDL', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRMoralResponsibility
        IF  (  Update(comp_PRMoralResponsibility))
        BEGIN
            SET @OldValue =  @del_comp_PRMoralResponsibility
            SET @NewValue =  @ins_comp_PRMoralResponsibility
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRMoralResponsibility', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRSpecialHandlingInstruction
        IF  (  Update(comp_PRSpecialHandlingInstruction))
        BEGIN
            SET @OldValue =  @del_comp_PRSpecialHandlingInstruction
            SET @NewValue =  @ins_comp_PRSpecialHandlingInstruction
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRSpecialHandlingInstruction', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRHandlesInvoicing
        IF  (  Update(comp_PRHandlesInvoicing))
        BEGIN
            SET @OldValue =  @del_comp_PRHandlesInvoicing
            SET @NewValue =  @ins_comp_PRHandlesInvoicing
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRHandlesInvoicing', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRReceiveLRL
        IF  (  Update(comp_PRReceiveLRL))
        BEGIN
            SET @OldValue =  @del_comp_PRReceiveLRL
            SET @NewValue =  @ins_comp_PRReceiveLRL
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRReceiveLRL', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRTMFMAward
        IF  (  Update(comp_PRTMFMAward))
        BEGIN
            SET @OldValue =  @del_comp_PRTMFMAward
            SET @NewValue =  @ins_comp_PRTMFMAward
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRTMFMAward', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRTMFMAwardDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_comp_PRTMFMAwardDate, @ins_comp_PRTMFMAwardDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_comp_PRTMFMAwardDate IS NOT NULL AND convert(varchar,@del_comp_PRTMFMAwardDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_comp_PRTMFMAwardDate)
            IF (@ins_comp_PRTMFMAwardDate IS NOT NULL AND convert(varchar,@ins_comp_PRTMFMAwardDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_comp_PRTMFMAwardDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRTMFMAwardDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRTMFMCandidate
        IF  (  Update(comp_PRTMFMCandidate))
        BEGIN
            SET @OldValue =  @del_comp_PRTMFMCandidate
            SET @NewValue =  @ins_comp_PRTMFMCandidate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRTMFMCandidate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRTMFMCandidateDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_comp_PRTMFMCandidateDate, @ins_comp_PRTMFMCandidateDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_comp_PRTMFMCandidateDate IS NOT NULL AND convert(varchar,@del_comp_PRTMFMCandidateDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_comp_PRTMFMCandidateDate)
            IF (@ins_comp_PRTMFMCandidateDate IS NOT NULL AND convert(varchar,@ins_comp_PRTMFMCandidateDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_comp_PRTMFMCandidateDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRTMFMCandidateDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRAdministrativeUsage
        IF  (  Update(comp_PRAdministrativeUsage))
        BEGIN
            SET @OldValue =  @del_comp_PRAdministrativeUsage
            SET @NewValue =  @ins_comp_PRAdministrativeUsage
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRAdministrativeUsage', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRReceiveTES
        IF  (  Update(comp_PRReceiveTES))
        BEGIN
            SET @OldValue =  @del_comp_PRReceiveTES
            SET @NewValue =  @ins_comp_PRReceiveTES
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRReceiveTES', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRCreditWorthCap
        IF  (  Update(comp_PRCreditWorthCap))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prcw_Name FROM PRCreditWorthRating WITH (NOLOCK) 
                WHERE prcw_CreditWorthRatingId = @ins_comp_PRCreditWorthCap
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_comp_PRCreditWorthCap))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prcw_Name FROM PRCreditWorthRating WITH (NOLOCK) 
                WHERE prcw_CreditWorthRatingId = @del_comp_PRCreditWorthCap
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_comp_PRCreditWorthCap))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRCreditWorthCap', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRCreditWorthCapReason
        IF  (  Update(comp_PRCreditWorthCapReason))
        BEGIN
            SET @OldValue =  @del_comp_PRCreditWorthCapReason
            SET @NewValue =  @ins_comp_PRCreditWorthCapReason
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRCreditWorthCapReason', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRConfidentialFS
        IF  (  Update(comp_PRConfidentialFS))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='comp_PRConfidentialFS' AND capt_code = @ins_comp_PRConfidentialFS
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_comp_PRConfidentialFS)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='comp_PRConfidentialFS' AND capt_code = @del_comp_PRConfidentialFS
            SET @OldValue = COALESCE(@NewValueTemp,  @del_comp_PRConfidentialFS)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRConfidentialFS', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRUnattributedOwnerPct
        IF  (  Update(comp_PRUnattributedOwnerPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_comp_PRUnattributedOwnerPct)
            SET @NewValue =  convert(varchar(max), @ins_comp_PRUnattributedOwnerPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRUnattributedOwnerPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRUnattributedOwnerDesc
        IF  (  Update(comp_PRUnattributedOwnerDesc))
        BEGIN
            SET @OldValue =  @del_comp_PRUnattributedOwnerDesc
            SET @NewValue =  @ins_comp_PRUnattributedOwnerDesc
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRUnattributedOwnerDesc', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRBusinessReport
        IF  (  Update(comp_PRBusinessReport))
        BEGIN
            SET @OldValue =  @del_comp_PRBusinessReport
            SET @NewValue =  @ins_comp_PRBusinessReport
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRBusinessReport', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRPrincipalsBackgroundText
        IF  (  Update(comp_PRPrincipalsBackgroundText))
        BEGIN
            SET @OldValue =  @del_comp_PRPrincipalsBackgroundText
            SET @NewValue =  @ins_comp_PRPrincipalsBackgroundText
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRPrincipalsBackgroundText', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRWebActivated
        IF  (  Update(comp_PRWebActivated))
        BEGIN
            SET @OldValue =  @del_comp_PRWebActivated
            SET @NewValue =  @ins_comp_PRWebActivated
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRWebActivated', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRWebActivatedDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_comp_PRWebActivatedDate, @ins_comp_PRWebActivatedDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_comp_PRWebActivatedDate IS NOT NULL AND convert(varchar,@del_comp_PRWebActivatedDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_comp_PRWebActivatedDate)
            IF (@ins_comp_PRWebActivatedDate IS NOT NULL AND convert(varchar,@ins_comp_PRWebActivatedDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_comp_PRWebActivatedDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRWebActivatedDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRServicesThroughCompanyId
        IF  (  Update(comp_PRServicesThroughCompanyId))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_comp_PRServicesThroughCompanyId)
            SET @NewValue =  convert(varchar(max), @ins_comp_PRServicesThroughCompanyId)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRServicesThroughCompanyId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRIndustryType
        IF  (  Update(comp_PRIndustryType))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='comp_PRIndustryType' AND capt_code = @ins_comp_PRIndustryType
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_comp_PRIndustryType)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='comp_PRIndustryType' AND capt_code = @del_comp_PRIndustryType
            SET @OldValue = COALESCE(@NewValueTemp,  @del_comp_PRIndustryType)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRIndustryType', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRReceivesBBScoreReport
        IF  (  Update(comp_PRReceivesBBScoreReport))
        BEGIN
            SET @OldValue =  @del_comp_PRReceivesBBScoreReport
            SET @NewValue =  @ins_comp_PRReceivesBBScoreReport
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRReceivesBBScoreReport', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRUnconfirmed
        IF  (  Update(comp_PRUnconfirmed))
        BEGIN
            SET @OldValue =  @del_comp_PRUnconfirmed
            SET @NewValue =  @ins_comp_PRUnconfirmed
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRUnconfirmed', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRPublishPayIndicator
        IF  (  Update(comp_PRPublishPayIndicator))
        BEGIN
            SET @OldValue =  @del_comp_PRPublishPayIndicator
            SET @NewValue =  @ins_comp_PRPublishPayIndicator
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRPublishPayIndicator', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PROnlineOnly
        IF  (  Update(comp_PROnlineOnly))
        BEGIN
            SET @OldValue =  @del_comp_PROnlineOnly
            SET @NewValue =  @ins_comp_PROnlineOnly
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PROnlineOnly', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRARReportAccess
        IF  (  Update(comp_PRARReportAccess))
        BEGIN
            SET @OldValue =  @del_comp_PRARReportAccess
            SET @NewValue =  @ins_comp_PRARReportAccess
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRARReportAccess', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE Company SET 
        Company.Comp_CompanyId=i.Comp_CompanyId, 
        Company.Comp_PrimaryPersonId=i.Comp_PrimaryPersonId, 
        Company.Comp_PrimaryAddressId=i.Comp_PrimaryAddressId, 
        Company.Comp_PrimaryUserId=i.Comp_PrimaryUserId, 
        Company.Comp_Name=i.Comp_Name, 
        Company.Comp_Type=i.Comp_Type, 
        Company.Comp_Status=i.Comp_Status, 
        Company.Comp_Source=i.Comp_Source, 
        Company.Comp_Territory=i.Comp_Territory, 
        Company.Comp_Revenue=i.Comp_Revenue, 
        Company.Comp_Employees=i.Comp_Employees, 
        Company.Comp_Sector=i.Comp_Sector, 
        Company.Comp_IndCode=i.Comp_IndCode, 
        Company.Comp_WebSite=i.Comp_WebSite, 
        Company.Comp_MailRestriction=i.Comp_MailRestriction, 
        Company.Comp_CreatedBy=i.Comp_CreatedBy, 
        Company.Comp_CreatedDate=dbo.ufn_GetAccpacDate(i.Comp_CreatedDate), 
        Company.Comp_UpdatedBy=i.Comp_UpdatedBy, 
        Company.Comp_UpdatedDate=dbo.ufn_GetAccpacDate(i.Comp_UpdatedDate), 
        Company.Comp_TimeStamp=dbo.ufn_GetAccpacDate(i.Comp_TimeStamp), 
        Company.Comp_Deleted=i.Comp_Deleted, 
        Company.Comp_LibraryDir=i.Comp_LibraryDir, 
        Company.Comp_SegmentID=i.Comp_SegmentID, 
        Company.Comp_ChannelID=i.Comp_ChannelID, 
        Company.Comp_SecTerr=i.Comp_SecTerr, 
        Company.Comp_WorkflowId=i.Comp_WorkflowId, 
        Company.Comp_UploadDate=dbo.ufn_GetAccpacDate(i.Comp_UploadDate), 
        Company.comp_SLAId=i.comp_SLAId, 
        Company.comp_PRHQId=i.comp_PRHQId, 
        Company.comp_PRCorrTradestyle=i.comp_PRCorrTradestyle, 
        Company.comp_PRBookTradestyle=i.comp_PRBookTradestyle, 
        Company.comp_PRSubordinationAgrProvided=i.comp_PRSubordinationAgrProvided, 
        Company.comp_PRSubordinationAgrDate=dbo.ufn_GetAccpacDate(i.comp_PRSubordinationAgrDate), 
        Company.comp_PRExcludeFSRequest=i.comp_PRExcludeFSRequest, 
        Company.comp_PRSpecialInstruction=i.comp_PRSpecialInstruction, 
        Company.comp_PRDataQualityTier=i.comp_PRDataQualityTier, 
        Company.comp_PRListingCityId=i.comp_PRListingCityId, 
        Company.comp_PRListingStatus=i.comp_PRListingStatus, 
        Company.comp_PRAccountTier=i.comp_PRAccountTier, 
        Company.comp_PRBusinessStatus=i.comp_PRBusinessStatus, 
        Company.comp_PRTradestyle1=i.comp_PRTradestyle1, 
        Company.comp_PRTradestyle2=i.comp_PRTradestyle2, 
        Company.comp_PRTradestyle3=i.comp_PRTradestyle3, 
        Company.comp_PRTradestyle4=i.comp_PRTradestyle4, 
        Company.comp_PRLegalName=i.comp_PRLegalName, 
        Company.comp_PROriginalName=i.comp_PROriginalName, 
        Company.comp_PROldName1=i.comp_PROldName1, 
        Company.comp_PROldName1Date=dbo.ufn_GetAccpacDate(i.comp_PROldName1Date), 
        Company.comp_PROldName2=i.comp_PROldName2, 
        Company.comp_PROldName2Date=dbo.ufn_GetAccpacDate(i.comp_PROldName2Date), 
        Company.comp_PROldName3=i.comp_PROldName3, 
        Company.comp_PROldName3Date=dbo.ufn_GetAccpacDate(i.comp_PROldName3Date), 
        Company.comp_PRType=i.comp_PRType, 
        Company.comp_PRPublishUnloadHours=i.comp_PRPublishUnloadHours, 
        Company.comp_PRPublishDL=i.comp_PRPublishDL, 
        Company.comp_PRMoralResponsibility=i.comp_PRMoralResponsibility, 
        Company.comp_PRSpecialHandlingInstruction=i.comp_PRSpecialHandlingInstruction, 
        Company.comp_PRHandlesInvoicing=i.comp_PRHandlesInvoicing, 
        Company.comp_PRReceiveLRL=i.comp_PRReceiveLRL, 
        Company.comp_PRTMFMAward=i.comp_PRTMFMAward, 
        Company.comp_PRTMFMAwardDate=dbo.ufn_GetAccpacDate(i.comp_PRTMFMAwardDate), 
        Company.comp_PRTMFMCandidate=i.comp_PRTMFMCandidate, 
        Company.comp_PRTMFMCandidateDate=dbo.ufn_GetAccpacDate(i.comp_PRTMFMCandidateDate), 
        Company.comp_PRTMFMComments=i.comp_PRTMFMComments, 
        Company.comp_PRAdministrativeUsage=i.comp_PRAdministrativeUsage, 
        Company.comp_PRInvestigationMethodGroup=i.comp_PRInvestigationMethodGroup, 
        Company.comp_PRReceiveTES=i.comp_PRReceiveTES, 
        Company.comp_PRCreditWorthCap=i.comp_PRCreditWorthCap, 
        Company.comp_PRCreditWorthCapReason=i.comp_PRCreditWorthCapReason, 
        Company.comp_PRConfidentialFS=i.comp_PRConfidentialFS, 
        Company.comp_PRJeopardyDate=dbo.ufn_GetAccpacDate(i.comp_PRJeopardyDate), 
        Company.comp_PRLogo=i.comp_PRLogo, 
        Company.comp_PRUnattributedOwnerPct=i.comp_PRUnattributedOwnerPct, 
        Company.comp_PRUnattributedOwnerDesc=i.comp_PRUnattributedOwnerDesc, 
        Company.comp_PRConnectionListDate=dbo.ufn_GetAccpacDate(i.comp_PRConnectionListDate), 
        Company.comp_PRBusinessReport=i.comp_PRBusinessReport, 
        Company.comp_PRPrincipalsBackgroundText=i.comp_PRPrincipalsBackgroundText, 
        Company.comp_PRWebActivated=i.comp_PRWebActivated, 
        Company.comp_PRWebActivatedDate=dbo.ufn_GetAccpacDate(i.comp_PRWebActivatedDate), 
        Company.comp_PRServicesThroughCompanyId=i.comp_PRServicesThroughCompanyId, 
        Company.comp_PRIndustryType=i.comp_PRIndustryType, 
        Company.comp_PRReceivesBBScoreReport=i.comp_PRReceivesBBScoreReport, 
        Company.comp_PRFinancialStatementDate=dbo.ufn_GetAccpacDate(i.comp_PRFinancialStatementDate), 
        Company.comp_PRTESNonresponder=i.comp_PRTESNonresponder, 
        Company.comp_PRMethodSourceReceived=i.comp_PRMethodSourceReceived, 
        Company.comp_PRCommunicationLanguage=i.comp_PRCommunicationLanguage, 
        Company.comp_PRTradestyleFlag=i.comp_PRTradestyleFlag, 
        Company.comp_DLBillFlag=i.comp_DLBillFlag, 
        Company.comp_PRReceiveCSSurvey=i.comp_PRReceiveCSSurvey, 
        Company.comp_PRReceivePromoFaxes=i.comp_PRReceivePromoFaxes, 
        Company.comp_PRReceivePromoEmails=i.comp_PRReceivePromoEmails, 
        Company.comp_PRLastVisitDate=dbo.ufn_GetAccpacDate(i.comp_PRLastVisitDate), 
        Company.comp_PRLastVisitedBy=i.comp_PRLastVisitedBy, 
        Company.comp_PRListedDate=dbo.ufn_GetAccpacDate(i.comp_PRListedDate), 
        Company.comp_PRDelistedDate=dbo.ufn_GetAccpacDate(i.comp_PRDelistedDate), 
        Company.comp_PREBBTermsAcceptedDate=dbo.ufn_GetAccpacDate(i.comp_PREBBTermsAcceptedDate), 
        Company.comp_PRLastPublishedCSDate=dbo.ufn_GetAccpacDate(i.comp_PRLastPublishedCSDate), 
        Company.comp_PREBBTermsAcceptedBy=i.comp_PREBBTermsAcceptedBy, 
        Company.comp_PRUnconfirmed=i.comp_PRUnconfirmed, 
        Company.comp_PRSessionTrackerIDCheckDisabled=i.comp_PRSessionTrackerIDCheckDisabled, 
        Company.comp_PRIsEligibleForEquifaxData=i.comp_PRIsEligibleForEquifaxData, 
        Company.comp_PRLastLRLLetterDate=dbo.ufn_GetAccpacDate(i.comp_PRLastLRLLetterDate), 
        Company.comp_PRReceiveTESCode=i.comp_PRReceiveTESCode, 
        Company.comp_PRPublishPayIndicator=i.comp_PRPublishPayIndicator, 
        Company.comp_PRPublishLogo=i.comp_PRPublishLogo, 
        Company.comp_PRLogoChangedDate=dbo.ufn_GetAccpacDate(i.comp_PRLogoChangedDate), 
        Company.comp_PRLogoChangedBy=i.comp_PRLogoChangedBy, 
        Company.comp_PRHideLinkedInWidget=i.comp_PRHideLinkedInWidget, 
        Company.comp_PRServiceStartDate=dbo.ufn_GetAccpacDate(i.comp_PRServiceStartDate), 
        Company.comp_PRServiceEndDate=dbo.ufn_GetAccpacDate(i.comp_PRServiceEndDate), 
        Company.comp_PROriginalServiceStartDate=dbo.ufn_GetAccpacDate(i.comp_PROriginalServiceStartDate), 
        Company.comp_PRFinancialNotes=i.comp_PRFinancialNotes, 
        Company.comp_PRTradeActivityNotes=i.comp_PRTradeActivityNotes, 
        Company.comp_PROnlineOnly=i.comp_PROnlineOnly, 
        Company.comp_PRExcludeAsEquifaxSubject=i.comp_PRExcludeAsEquifaxSubject, 
        Company.comp_PRLocalSource=i.comp_PRLocalSource, 
        Company.comp_PRARReportAccess=i.comp_PRARReportAccess, 
        Company.comp_PRHasCustomPersonSort=i.comp_PRHasCustomPersonSort, 
        Company.comp_PRExcludeFromLocalSource=i.comp_PRExcludeFromLocalSource, 
        Company.comp_PRRetailerOnlineOnly=i.comp_PRRetailerOnlineOnly, 
        Company.comp_PRIsIntlTradeAssociation=i.comp_PRIsIntlTradeAssociation, 
        Company.comp_PRImporter=i.comp_PRImporter, 
        Company.comp_PRExcludeFromIntlTA=i.comp_PRExcludeFromIntlTA, 
        Company.comp_PROnlineOnlyReasonCode=i.comp_PROnlineOnlyReasonCode, 
        Company.comp_PRHasITAAccess=i.comp_PRHasITAAccess, 
        Company.comp_PRPublishBBScore=i.comp_PRPublishBBScore, 
        Company.comp_PRIgnoreTES=i.comp_PRIgnoreTES
        FROM inserted i 
          INNER JOIN Company ON i.Comp_CompanyId=Company.Comp_CompanyId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyBank_ioupd
 * 
 * Table:  PRCompanyBank
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyBank_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyBank_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyBank_ioupd
ON PRCompanyBank
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prcb_CompanyBankId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prcb_CompanyID, @UserId = i.prcb_UpdatedBy, @prcb_CompanyBankId = i.prcb_CompanyBankId
        FROM Inserted i
        INNER JOIN deleted d ON i.prcb_CompanyBankId = d.prcb_CompanyBankId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prcb_Name) OR
        Update (prcb_Address1) OR
        Update (prcb_Address2) OR
        Update (prcb_City) OR
        Update (prcb_State) OR
        Update (prcb_PostalCode) OR
        Update (prcb_Country) OR
        Update (prcb_Telephone) OR
        Update (prcb_Fax) OR
        Update (prcb_Website) OR
        Update (prcb_AdditionalInfo) OR
        Update (prcb_Publish) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Bank ' + convert(varchar,@prcb_CompanyBankId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prcb_Name nvarchar(100), @del_prcb_Name nvarchar(100)
        Declare @ins_prcb_Address1 nvarchar(50), @del_prcb_Address1 nvarchar(50)
        Declare @ins_prcb_Address2 nvarchar(50), @del_prcb_Address2 nvarchar(50)
        Declare @ins_prcb_City nvarchar(20), @del_prcb_City nvarchar(20)
        Declare @ins_prcb_State nvarchar(10), @del_prcb_State nvarchar(10)
        Declare @ins_prcb_PostalCode nvarchar(10), @del_prcb_PostalCode nvarchar(10)
        Declare @ins_prcb_Country nvarchar(50), @del_prcb_Country nvarchar(50)
        Declare @ins_prcb_Telephone nvarchar(20), @del_prcb_Telephone nvarchar(20)
        Declare @ins_prcb_Fax nvarchar(20), @del_prcb_Fax nvarchar(20)
        Declare @ins_prcb_Website nvarchar(100), @del_prcb_Website nvarchar(100)
        Declare @ins_prcb_AdditionalInfo varchar(max), @del_prcb_AdditionalInfo varchar(max)
        Declare @ins_prcb_Publish nchar(1), @del_prcb_Publish nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prcb_Name = i.prcb_Name, @del_prcb_Name = d.prcb_Name,
            @ins_prcb_Address1 = i.prcb_Address1, @del_prcb_Address1 = d.prcb_Address1,
            @ins_prcb_Address2 = i.prcb_Address2, @del_prcb_Address2 = d.prcb_Address2,
            @ins_prcb_City = i.prcb_City, @del_prcb_City = d.prcb_City,
            @ins_prcb_State = i.prcb_State, @del_prcb_State = d.prcb_State,
            @ins_prcb_PostalCode = i.prcb_PostalCode, @del_prcb_PostalCode = d.prcb_PostalCode,
            @ins_prcb_Country = i.prcb_Country, @del_prcb_Country = d.prcb_Country,
            @ins_prcb_Telephone = i.prcb_Telephone, @del_prcb_Telephone = d.prcb_Telephone,
            @ins_prcb_Fax = i.prcb_Fax, @del_prcb_Fax = d.prcb_Fax,
            @ins_prcb_Website = i.prcb_Website, @del_prcb_Website = d.prcb_Website,
            @ins_prcb_AdditionalInfo = i.prcb_AdditionalInfo, @del_prcb_AdditionalInfo = d.prcb_AdditionalInfo,
            @ins_prcb_Publish = i.prcb_Publish, @del_prcb_Publish = d.prcb_Publish
        FROM Inserted i
        INNER JOIN deleted d ON i.prcb_CompanyBankId = d.prcb_CompanyBankId

        -- prcb_Name
        IF  (  Update(prcb_Name))
        BEGIN
            SET @OldValue =  @del_prcb_Name
            SET @NewValue =  @ins_prcb_Name
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_Name', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_Address1
        IF  (  Update(prcb_Address1))
        BEGIN
            SET @OldValue =  @del_prcb_Address1
            SET @NewValue =  @ins_prcb_Address1
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_Address1', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_Address2
        IF  (  Update(prcb_Address2))
        BEGIN
            SET @OldValue =  @del_prcb_Address2
            SET @NewValue =  @ins_prcb_Address2
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_Address2', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_City
        IF  (  Update(prcb_City))
        BEGIN
            SET @OldValue =  @del_prcb_City
            SET @NewValue =  @ins_prcb_City
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_City', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_State
        IF  (  Update(prcb_State))
        BEGIN
            SET @OldValue =  @del_prcb_State
            SET @NewValue =  @ins_prcb_State
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_State', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_PostalCode
        IF  (  Update(prcb_PostalCode))
        BEGIN
            SET @OldValue =  @del_prcb_PostalCode
            SET @NewValue =  @ins_prcb_PostalCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_PostalCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_Country
        IF  (  Update(prcb_Country))
        BEGIN
            SET @OldValue =  @del_prcb_Country
            SET @NewValue =  @ins_prcb_Country
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_Country', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_Telephone
        IF  (  Update(prcb_Telephone))
        BEGIN
            SET @OldValue =  @del_prcb_Telephone
            SET @NewValue =  @ins_prcb_Telephone
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_Telephone', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_Fax
        IF  (  Update(prcb_Fax))
        BEGIN
            SET @OldValue =  @del_prcb_Fax
            SET @NewValue =  @ins_prcb_Fax
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_Fax', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_Website
        IF  (  Update(prcb_Website))
        BEGIN
            SET @OldValue =  @del_prcb_Website
            SET @NewValue =  @ins_prcb_Website
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_Website', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_AdditionalInfo
        IF  (  Update(prcb_AdditionalInfo))
        BEGIN
            SET @OldValue =  @del_prcb_AdditionalInfo
            SET @NewValue =  @ins_prcb_AdditionalInfo
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_AdditionalInfo', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcb_Publish
        IF  (  Update(prcb_Publish))
        BEGIN
            SET @OldValue =  @del_prcb_Publish
            SET @NewValue =  @ins_prcb_Publish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_Publish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyBank SET 
        PRCompanyBank.prcb_CompanyBankId=i.prcb_CompanyBankId, 
        PRCompanyBank.prcb_CreatedBy=i.prcb_CreatedBy, 
        PRCompanyBank.prcb_CreatedDate=dbo.ufn_GetAccpacDate(i.prcb_CreatedDate), 
        PRCompanyBank.prcb_UpdatedBy=i.prcb_UpdatedBy, 
        PRCompanyBank.prcb_UpdatedDate=dbo.ufn_GetAccpacDate(i.prcb_UpdatedDate), 
        PRCompanyBank.prcb_TimeStamp=dbo.ufn_GetAccpacDate(i.prcb_TimeStamp), 
        PRCompanyBank.prcb_Deleted=i.prcb_Deleted, 
        PRCompanyBank.prcb_WorkflowId=i.prcb_WorkflowId, 
        PRCompanyBank.prcb_Secterr=i.prcb_Secterr, 
        PRCompanyBank.prcb_CompanyId=i.prcb_CompanyId, 
        PRCompanyBank.prcb_Name=i.prcb_Name, 
        PRCompanyBank.prcb_Address1=i.prcb_Address1, 
        PRCompanyBank.prcb_Address2=i.prcb_Address2, 
        PRCompanyBank.prcb_City=i.prcb_City, 
        PRCompanyBank.prcb_State=i.prcb_State, 
        PRCompanyBank.prcb_PostalCode=i.prcb_PostalCode, 
        PRCompanyBank.prcb_Country=i.prcb_Country, 
        PRCompanyBank.prcb_Telephone=i.prcb_Telephone, 
        PRCompanyBank.prcb_Fax=i.prcb_Fax, 
        PRCompanyBank.prcb_Website=i.prcb_Website, 
        PRCompanyBank.prcb_AdditionalInfo=i.prcb_AdditionalInfo, 
        PRCompanyBank.prcb_Publish=i.prcb_Publish
        FROM inserted i 
          INNER JOIN PRCompanyBank ON i.prcb_CompanyBankId=PRCompanyBank.prcb_CompanyBankId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyBank_insdel
 * 
 * Table:  PRCompanyBank
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyBank_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyBank_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyBank_insdel
ON PRCompanyBank
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prcb_CompanyBankId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prcb_CompanyID int, prcb_Name nvarchar(100))
    INSERT INTO @ProcessTable
        SELECT 'Insert',prcb_CompanyID,prcb_Name
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prcb_CompanyID,prcb_Name
        FROM Deleted


    Declare @prcb_Name nvarchar(100)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prcb_CompanyID,prcb_Name
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prcb_Name
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_CompanyId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Bank ' + convert(varchar,@prcb_CompanyBankId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = convert(varchar(50), @prcb_Name)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 
            'prcb_Name', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prcb_Name
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyBrand_ioupd
 * 
 * Table:  PRCompanyBrand
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyBrand_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyBrand_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyBrand_ioupd
ON PRCompanyBrand
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prc3_CompanyBrandId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prc3_CompanyID, @UserId = i.prc3_UpdatedBy, @prc3_CompanyBrandId = i.prc3_CompanyBrandId
        FROM Inserted i
        INNER JOIN deleted d ON i.prc3_CompanyBrandId = d.prc3_CompanyBrandId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prc3_Brand) OR
        Update (prc3_Description) OR
        Update (prc3_ViewableImageLocation) OR
        Update (prc3_PrintableImageLocation) OR
        Update (prc3_OwningCompany) OR
        Update (prc3_Publish) OR
        Update (prc3_Sequence) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Brand ' + convert(varchar,@prc3_CompanyBrandId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prc3_Brand nvarchar(100), @del_prc3_Brand nvarchar(100)
        Declare @ins_prc3_Description varchar(max), @del_prc3_Description varchar(max)
        Declare @ins_prc3_ViewableImageLocation nvarchar(100), @del_prc3_ViewableImageLocation nvarchar(100)
        Declare @ins_prc3_PrintableImageLocation nvarchar(100), @del_prc3_PrintableImageLocation nvarchar(100)
        Declare @ins_prc3_OwningCompany nvarchar(100), @del_prc3_OwningCompany nvarchar(100)
        Declare @ins_prc3_Publish nchar(1), @del_prc3_Publish nchar(1)
        Declare @ins_prc3_Sequence int, @del_prc3_Sequence int
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prc3_Brand = i.prc3_Brand, @del_prc3_Brand = d.prc3_Brand,
            @ins_prc3_Description = i.prc3_Description, @del_prc3_Description = d.prc3_Description,
            @ins_prc3_ViewableImageLocation = i.prc3_ViewableImageLocation, @del_prc3_ViewableImageLocation = d.prc3_ViewableImageLocation,
            @ins_prc3_PrintableImageLocation = i.prc3_PrintableImageLocation, @del_prc3_PrintableImageLocation = d.prc3_PrintableImageLocation,
            @ins_prc3_OwningCompany = i.prc3_OwningCompany, @del_prc3_OwningCompany = d.prc3_OwningCompany,
            @ins_prc3_Publish = i.prc3_Publish, @del_prc3_Publish = d.prc3_Publish,
            @ins_prc3_Sequence = i.prc3_Sequence, @del_prc3_Sequence = d.prc3_Sequence
        FROM Inserted i
        INNER JOIN deleted d ON i.prc3_CompanyBrandId = d.prc3_CompanyBrandId

        -- prc3_Brand
        IF  (  Update(prc3_Brand))
        BEGIN
            SET @OldValue =  @del_prc3_Brand
            SET @NewValue =  @ins_prc3_Brand
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 'prc3_Brand', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc3_Description
        IF  (  Update(prc3_Description))
        BEGIN
            SET @OldValue =  @del_prc3_Description
            SET @NewValue =  @ins_prc3_Description
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 'prc3_Description', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc3_ViewableImageLocation
        IF  (  Update(prc3_ViewableImageLocation))
        BEGIN
            SET @OldValue =  @del_prc3_ViewableImageLocation
            SET @NewValue =  @ins_prc3_ViewableImageLocation
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 'prc3_ViewableImageLocation', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc3_PrintableImageLocation
        IF  (  Update(prc3_PrintableImageLocation))
        BEGIN
            SET @OldValue =  @del_prc3_PrintableImageLocation
            SET @NewValue =  @ins_prc3_PrintableImageLocation
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 'prc3_PrintableImageLocation', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc3_OwningCompany
        IF  (  Update(prc3_OwningCompany))
        BEGIN
            SET @OldValue =  @del_prc3_OwningCompany
            SET @NewValue =  @ins_prc3_OwningCompany
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 'prc3_OwningCompany', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc3_Publish
        IF  (  Update(prc3_Publish))
        BEGIN
            SET @OldValue =  @del_prc3_Publish
            SET @NewValue =  @ins_prc3_Publish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 'prc3_Publish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc3_Sequence
        IF  (  Update(prc3_Sequence))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prc3_Sequence)
            SET @NewValue =  convert(varchar(max), @ins_prc3_Sequence)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 'prc3_Sequence', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyBrand SET 
        PRCompanyBrand.prc3_CompanyBrandId=i.prc3_CompanyBrandId, 
        PRCompanyBrand.prc3_CreatedBy=i.prc3_CreatedBy, 
        PRCompanyBrand.prc3_CreatedDate=dbo.ufn_GetAccpacDate(i.prc3_CreatedDate), 
        PRCompanyBrand.prc3_UpdatedBy=i.prc3_UpdatedBy, 
        PRCompanyBrand.prc3_UpdatedDate=dbo.ufn_GetAccpacDate(i.prc3_UpdatedDate), 
        PRCompanyBrand.prc3_TimeStamp=dbo.ufn_GetAccpacDate(i.prc3_TimeStamp), 
        PRCompanyBrand.prc3_Deleted=i.prc3_Deleted, 
        PRCompanyBrand.prc3_WorkflowId=i.prc3_WorkflowId, 
        PRCompanyBrand.prc3_Secterr=i.prc3_Secterr, 
        PRCompanyBrand.prc3_CompanyId=i.prc3_CompanyId, 
        PRCompanyBrand.prc3_Brand=i.prc3_Brand, 
        PRCompanyBrand.prc3_Description=i.prc3_Description, 
        PRCompanyBrand.prc3_ViewableImageLocation=i.prc3_ViewableImageLocation, 
        PRCompanyBrand.prc3_PrintableImageLocation=i.prc3_PrintableImageLocation, 
        PRCompanyBrand.prc3_OwningCompany=i.prc3_OwningCompany, 
        PRCompanyBrand.prc3_Publish=i.prc3_Publish, 
        PRCompanyBrand.prc3_Sequence=i.prc3_Sequence
        FROM inserted i 
          INNER JOIN PRCompanyBrand ON i.prc3_CompanyBrandId=PRCompanyBrand.prc3_CompanyBrandId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyBrand_insdel
 * 
 * Table:  PRCompanyBrand
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyBrand_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyBrand_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyBrand_insdel
ON PRCompanyBrand
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prc3_CompanyBrandId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prc3_CompanyID int, prc3_Brand nvarchar(100))
    INSERT INTO @ProcessTable
        SELECT 'Insert',prc3_CompanyID,prc3_Brand
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prc3_CompanyID,prc3_Brand
        FROM Deleted


    Declare @prc3_Brand nvarchar(100)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prc3_CompanyID,prc3_Brand
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prc3_Brand
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_CompanyId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Brand ' + convert(varchar,@prc3_CompanyBrandId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = convert(varchar(50), @prc3_Brand)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 
            'prc3_Brand', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prc3_Brand
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyClassification_ioupd
 * 
 * Table:  PRCompanyClassification
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyClassification_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyClassification_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyClassification_ioupd
ON PRCompanyClassification
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prc2_CompanyClassificationId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prc2_CompanyID, @UserId = i.prc2_UpdatedBy, @prc2_CompanyClassificationId = i.prc2_CompanyClassificationId
        FROM Inserted i
        INNER JOIN deleted d ON i.prc2_CompanyClassificationId = d.prc2_CompanyClassificationId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prc2_Percentage) OR
        Update (prc2_PercentageSource) OR
        Update (prc2_NumberOfStores) OR
        Update (prc2_ComboStores) OR
        Update (prc2_NumberOfComboStores) OR
        Update (prc2_ConvenienceStores) OR
        Update (prc2_NumberOfConvenienceStores) OR
        Update (prc2_GourmetStores) OR
        Update (prc2_NumberOfGourmetStores) OR
        Update (prc2_HealthFoodStores) OR
        Update (prc2_NumberOfHealthFoodStores) OR
        Update (prc2_ProduceOnlyStores) OR
        Update (prc2_NumberOfProduceOnlyStores) OR
        Update (prc2_SupermarketStores) OR
        Update (prc2_NumberOfSupermarketStores) OR
        Update (prc2_SuperStores) OR
        Update (prc2_NumberOfSuperStores) OR
        Update (prc2_WarehouseStores) OR
        Update (prc2_NumberOfWarehouseStores) OR
        Update (prc2_Sequence) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Classification ' + convert(varchar,@prc2_CompanyClassificationId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prc2_Percentage numeric, @del_prc2_Percentage numeric
        Declare @ins_prc2_PercentageSource nchar(1), @del_prc2_PercentageSource nchar(1)
        Declare @ins_prc2_NumberOfStores nvarchar(40), @del_prc2_NumberOfStores nvarchar(40)
        Declare @ins_prc2_ComboStores nchar(1), @del_prc2_ComboStores nchar(1)
        Declare @ins_prc2_NumberOfComboStores nvarchar(40), @del_prc2_NumberOfComboStores nvarchar(40)
        Declare @ins_prc2_ConvenienceStores nchar(1), @del_prc2_ConvenienceStores nchar(1)
        Declare @ins_prc2_NumberOfConvenienceStores nvarchar(40), @del_prc2_NumberOfConvenienceStores nvarchar(40)
        Declare @ins_prc2_GourmetStores nchar(1), @del_prc2_GourmetStores nchar(1)
        Declare @ins_prc2_NumberOfGourmetStores nvarchar(40), @del_prc2_NumberOfGourmetStores nvarchar(40)
        Declare @ins_prc2_HealthFoodStores nchar(1), @del_prc2_HealthFoodStores nchar(1)
        Declare @ins_prc2_NumberOfHealthFoodStores nvarchar(40), @del_prc2_NumberOfHealthFoodStores nvarchar(40)
        Declare @ins_prc2_ProduceOnlyStores nchar(1), @del_prc2_ProduceOnlyStores nchar(1)
        Declare @ins_prc2_NumberOfProduceOnlyStores nvarchar(40), @del_prc2_NumberOfProduceOnlyStores nvarchar(40)
        Declare @ins_prc2_SupermarketStores nchar(1), @del_prc2_SupermarketStores nchar(1)
        Declare @ins_prc2_NumberOfSupermarketStores nvarchar(40), @del_prc2_NumberOfSupermarketStores nvarchar(40)
        Declare @ins_prc2_SuperStores nchar(1), @del_prc2_SuperStores nchar(1)
        Declare @ins_prc2_NumberOfSuperStores nvarchar(40), @del_prc2_NumberOfSuperStores nvarchar(40)
        Declare @ins_prc2_WarehouseStores nchar(1), @del_prc2_WarehouseStores nchar(1)
        Declare @ins_prc2_NumberOfWarehouseStores nvarchar(40), @del_prc2_NumberOfWarehouseStores nvarchar(40)
        Declare @ins_prc2_Sequence int, @del_prc2_Sequence int
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prc2_Percentage = i.prc2_Percentage, @del_prc2_Percentage = d.prc2_Percentage,
            @ins_prc2_PercentageSource = i.prc2_PercentageSource, @del_prc2_PercentageSource = d.prc2_PercentageSource,
            @ins_prc2_NumberOfStores = i.prc2_NumberOfStores, @del_prc2_NumberOfStores = d.prc2_NumberOfStores,
            @ins_prc2_ComboStores = i.prc2_ComboStores, @del_prc2_ComboStores = d.prc2_ComboStores,
            @ins_prc2_NumberOfComboStores = i.prc2_NumberOfComboStores, @del_prc2_NumberOfComboStores = d.prc2_NumberOfComboStores,
            @ins_prc2_ConvenienceStores = i.prc2_ConvenienceStores, @del_prc2_ConvenienceStores = d.prc2_ConvenienceStores,
            @ins_prc2_NumberOfConvenienceStores = i.prc2_NumberOfConvenienceStores, @del_prc2_NumberOfConvenienceStores = d.prc2_NumberOfConvenienceStores,
            @ins_prc2_GourmetStores = i.prc2_GourmetStores, @del_prc2_GourmetStores = d.prc2_GourmetStores,
            @ins_prc2_NumberOfGourmetStores = i.prc2_NumberOfGourmetStores, @del_prc2_NumberOfGourmetStores = d.prc2_NumberOfGourmetStores,
            @ins_prc2_HealthFoodStores = i.prc2_HealthFoodStores, @del_prc2_HealthFoodStores = d.prc2_HealthFoodStores,
            @ins_prc2_NumberOfHealthFoodStores = i.prc2_NumberOfHealthFoodStores, @del_prc2_NumberOfHealthFoodStores = d.prc2_NumberOfHealthFoodStores,
            @ins_prc2_ProduceOnlyStores = i.prc2_ProduceOnlyStores, @del_prc2_ProduceOnlyStores = d.prc2_ProduceOnlyStores,
            @ins_prc2_NumberOfProduceOnlyStores = i.prc2_NumberOfProduceOnlyStores, @del_prc2_NumberOfProduceOnlyStores = d.prc2_NumberOfProduceOnlyStores,
            @ins_prc2_SupermarketStores = i.prc2_SupermarketStores, @del_prc2_SupermarketStores = d.prc2_SupermarketStores,
            @ins_prc2_NumberOfSupermarketStores = i.prc2_NumberOfSupermarketStores, @del_prc2_NumberOfSupermarketStores = d.prc2_NumberOfSupermarketStores,
            @ins_prc2_SuperStores = i.prc2_SuperStores, @del_prc2_SuperStores = d.prc2_SuperStores,
            @ins_prc2_NumberOfSuperStores = i.prc2_NumberOfSuperStores, @del_prc2_NumberOfSuperStores = d.prc2_NumberOfSuperStores,
            @ins_prc2_WarehouseStores = i.prc2_WarehouseStores, @del_prc2_WarehouseStores = d.prc2_WarehouseStores,
            @ins_prc2_NumberOfWarehouseStores = i.prc2_NumberOfWarehouseStores, @del_prc2_NumberOfWarehouseStores = d.prc2_NumberOfWarehouseStores,
            @ins_prc2_Sequence = i.prc2_Sequence, @del_prc2_Sequence = d.prc2_Sequence
        FROM Inserted i
        INNER JOIN deleted d ON i.prc2_CompanyClassificationId = d.prc2_CompanyClassificationId

        -- prc2_Percentage
        IF  (  Update(prc2_Percentage))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prc2_Percentage)
            SET @NewValue =  convert(varchar(max), @ins_prc2_Percentage)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_Percentage', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_PercentageSource
        IF  (  Update(prc2_PercentageSource))
        BEGIN
            SET @OldValue =  @del_prc2_PercentageSource
            SET @NewValue =  @ins_prc2_PercentageSource
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_PercentageSource', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_NumberOfStores
        IF  (  Update(prc2_NumberOfStores))
        BEGIN
            SET @OldValue =  @del_prc2_NumberOfStores
            SET @NewValue =  @ins_prc2_NumberOfStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_NumberOfStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_ComboStores
        IF  (  Update(prc2_ComboStores))
        BEGIN
            SET @OldValue =  @del_prc2_ComboStores
            SET @NewValue =  @ins_prc2_ComboStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_ComboStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_NumberOfComboStores
        IF  (  Update(prc2_NumberOfComboStores))
        BEGIN
            SET @OldValue =  @del_prc2_NumberOfComboStores
            SET @NewValue =  @ins_prc2_NumberOfComboStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_NumberOfComboStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_ConvenienceStores
        IF  (  Update(prc2_ConvenienceStores))
        BEGIN
            SET @OldValue =  @del_prc2_ConvenienceStores
            SET @NewValue =  @ins_prc2_ConvenienceStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_ConvenienceStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_NumberOfConvenienceStores
        IF  (  Update(prc2_NumberOfConvenienceStores))
        BEGIN
            SET @OldValue =  @del_prc2_NumberOfConvenienceStores
            SET @NewValue =  @ins_prc2_NumberOfConvenienceStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_NumberOfConvenienceStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_GourmetStores
        IF  (  Update(prc2_GourmetStores))
        BEGIN
            SET @OldValue =  @del_prc2_GourmetStores
            SET @NewValue =  @ins_prc2_GourmetStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_GourmetStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_NumberOfGourmetStores
        IF  (  Update(prc2_NumberOfGourmetStores))
        BEGIN
            SET @OldValue =  @del_prc2_NumberOfGourmetStores
            SET @NewValue =  @ins_prc2_NumberOfGourmetStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_NumberOfGourmetStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_HealthFoodStores
        IF  (  Update(prc2_HealthFoodStores))
        BEGIN
            SET @OldValue =  @del_prc2_HealthFoodStores
            SET @NewValue =  @ins_prc2_HealthFoodStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_HealthFoodStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_NumberOfHealthFoodStores
        IF  (  Update(prc2_NumberOfHealthFoodStores))
        BEGIN
            SET @OldValue =  @del_prc2_NumberOfHealthFoodStores
            SET @NewValue =  @ins_prc2_NumberOfHealthFoodStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_NumberOfHealthFoodStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_ProduceOnlyStores
        IF  (  Update(prc2_ProduceOnlyStores))
        BEGIN
            SET @OldValue =  @del_prc2_ProduceOnlyStores
            SET @NewValue =  @ins_prc2_ProduceOnlyStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_ProduceOnlyStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_NumberOfProduceOnlyStores
        IF  (  Update(prc2_NumberOfProduceOnlyStores))
        BEGIN
            SET @OldValue =  @del_prc2_NumberOfProduceOnlyStores
            SET @NewValue =  @ins_prc2_NumberOfProduceOnlyStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_NumberOfProduceOnlyStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_SupermarketStores
        IF  (  Update(prc2_SupermarketStores))
        BEGIN
            SET @OldValue =  @del_prc2_SupermarketStores
            SET @NewValue =  @ins_prc2_SupermarketStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_SupermarketStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_NumberOfSupermarketStores
        IF  (  Update(prc2_NumberOfSupermarketStores))
        BEGIN
            SET @OldValue =  @del_prc2_NumberOfSupermarketStores
            SET @NewValue =  @ins_prc2_NumberOfSupermarketStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_NumberOfSupermarketStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_SuperStores
        IF  (  Update(prc2_SuperStores))
        BEGIN
            SET @OldValue =  @del_prc2_SuperStores
            SET @NewValue =  @ins_prc2_SuperStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_SuperStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_NumberOfSuperStores
        IF  (  Update(prc2_NumberOfSuperStores))
        BEGIN
            SET @OldValue =  @del_prc2_NumberOfSuperStores
            SET @NewValue =  @ins_prc2_NumberOfSuperStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_NumberOfSuperStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_WarehouseStores
        IF  (  Update(prc2_WarehouseStores))
        BEGIN
            SET @OldValue =  @del_prc2_WarehouseStores
            SET @NewValue =  @ins_prc2_WarehouseStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_WarehouseStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_NumberOfWarehouseStores
        IF  (  Update(prc2_NumberOfWarehouseStores))
        BEGIN
            SET @OldValue =  @del_prc2_NumberOfWarehouseStores
            SET @NewValue =  @ins_prc2_NumberOfWarehouseStores
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_NumberOfWarehouseStores', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc2_Sequence
        IF  (  Update(prc2_Sequence))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prc2_Sequence)
            SET @NewValue =  convert(varchar(max), @ins_prc2_Sequence)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 'prc2_Sequence', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyClassification SET 
        PRCompanyClassification.prc2_CompanyClassificationId=i.prc2_CompanyClassificationId, 
        PRCompanyClassification.prc2_CreatedBy=i.prc2_CreatedBy, 
        PRCompanyClassification.prc2_CreatedDate=dbo.ufn_GetAccpacDate(i.prc2_CreatedDate), 
        PRCompanyClassification.prc2_UpdatedBy=i.prc2_UpdatedBy, 
        PRCompanyClassification.prc2_UpdatedDate=dbo.ufn_GetAccpacDate(i.prc2_UpdatedDate), 
        PRCompanyClassification.prc2_TimeStamp=dbo.ufn_GetAccpacDate(i.prc2_TimeStamp), 
        PRCompanyClassification.prc2_Deleted=i.prc2_Deleted, 
        PRCompanyClassification.prc2_WorkflowId=i.prc2_WorkflowId, 
        PRCompanyClassification.prc2_Secterr=i.prc2_Secterr, 
        PRCompanyClassification.prc2_CompanyId=i.prc2_CompanyId, 
        PRCompanyClassification.prc2_ClassificationId=i.prc2_ClassificationId, 
        PRCompanyClassification.prc2_Percentage=i.prc2_Percentage, 
        PRCompanyClassification.prc2_PercentageSource=i.prc2_PercentageSource, 
        PRCompanyClassification.prc2_NumberOfStores=i.prc2_NumberOfStores, 
        PRCompanyClassification.prc2_ComboStores=i.prc2_ComboStores, 
        PRCompanyClassification.prc2_NumberOfComboStores=i.prc2_NumberOfComboStores, 
        PRCompanyClassification.prc2_ConvenienceStores=i.prc2_ConvenienceStores, 
        PRCompanyClassification.prc2_NumberOfConvenienceStores=i.prc2_NumberOfConvenienceStores, 
        PRCompanyClassification.prc2_GourmetStores=i.prc2_GourmetStores, 
        PRCompanyClassification.prc2_NumberOfGourmetStores=i.prc2_NumberOfGourmetStores, 
        PRCompanyClassification.prc2_HealthFoodStores=i.prc2_HealthFoodStores, 
        PRCompanyClassification.prc2_NumberOfHealthFoodStores=i.prc2_NumberOfHealthFoodStores, 
        PRCompanyClassification.prc2_ProduceOnlyStores=i.prc2_ProduceOnlyStores, 
        PRCompanyClassification.prc2_NumberOfProduceOnlyStores=i.prc2_NumberOfProduceOnlyStores, 
        PRCompanyClassification.prc2_SupermarketStores=i.prc2_SupermarketStores, 
        PRCompanyClassification.prc2_NumberOfSupermarketStores=i.prc2_NumberOfSupermarketStores, 
        PRCompanyClassification.prc2_SuperStores=i.prc2_SuperStores, 
        PRCompanyClassification.prc2_NumberOfSuperStores=i.prc2_NumberOfSuperStores, 
        PRCompanyClassification.prc2_WarehouseStores=i.prc2_WarehouseStores, 
        PRCompanyClassification.prc2_NumberOfWarehouseStores=i.prc2_NumberOfWarehouseStores, 
        PRCompanyClassification.prc2_Sequence=i.prc2_Sequence
        FROM inserted i 
          INNER JOIN PRCompanyClassification ON i.prc2_CompanyClassificationId=PRCompanyClassification.prc2_CompanyClassificationId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyClassification_insdel
 * 
 * Table:  PRCompanyClassification
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyClassification_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyClassification_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyClassification_insdel
ON PRCompanyClassification
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prc2_CompanyClassificationId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prc2_CompanyID int, prc2_ClassificationId int)
    INSERT INTO @ProcessTable
        SELECT 'Insert',prc2_CompanyID,prc2_ClassificationId
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prc2_CompanyID,prc2_ClassificationId
        FROM Deleted


    Declare @prc2_ClassificationId int

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prc2_CompanyID,prc2_ClassificationId
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prc2_ClassificationId
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_CompanyId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Classification ' + convert(varchar,@prc2_CompanyClassificationId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prcl_Name FROM PRClassification WITH (NOLOCK) 
                WHERE prcl_ClassificationId = @prc2_ClassificationId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prc2_ClassificationId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Classification', @Action, 
            'prcl_Name', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prc2_ClassificationId
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyCommodityAttribute_ioupd
 * 
 * Table:  PRCompanyCommodityAttribute
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyCommodityAttribute_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyCommodityAttribute_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyCommodityAttribute_ioupd
ON PRCompanyCommodityAttribute
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prcca_CompanyCommodityAttributeId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prcca_CompanyID, @UserId = i.prcca_UpdatedBy, @prcca_CompanyCommodityAttributeId = i.prcca_CompanyCommodityAttributeId
        FROM Inserted i
        INNER JOIN deleted d ON i.prcca_CompanyCommodityAttributeId = d.prcca_CompanyCommodityAttributeId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prcca_Sequence) OR
        Update (prcca_Publish) OR
        Update (prcca_PublishWithGM) OR
        Update (prcca_PublishedDisplay) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Commodity Attribute ' + convert(varchar,@prcca_CompanyCommodityAttributeId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prcca_Sequence int, @del_prcca_Sequence int
        Declare @ins_prcca_Publish nchar(1), @del_prcca_Publish nchar(1)
        Declare @ins_prcca_PublishWithGM nchar(1), @del_prcca_PublishWithGM nchar(1)
        Declare @ins_prcca_PublishedDisplay nvarchar(50), @del_prcca_PublishedDisplay nvarchar(50)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prcca_Sequence = i.prcca_Sequence, @del_prcca_Sequence = d.prcca_Sequence,
            @ins_prcca_Publish = i.prcca_Publish, @del_prcca_Publish = d.prcca_Publish,
            @ins_prcca_PublishWithGM = i.prcca_PublishWithGM, @del_prcca_PublishWithGM = d.prcca_PublishWithGM,
            @ins_prcca_PublishedDisplay = i.prcca_PublishedDisplay, @del_prcca_PublishedDisplay = d.prcca_PublishedDisplay
        FROM Inserted i
        INNER JOIN deleted d ON i.prcca_CompanyCommodityAttributeId = d.prcca_CompanyCommodityAttributeId

        -- prcca_Sequence
        IF  (  Update(prcca_Sequence))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcca_Sequence)
            SET @NewValue =  convert(varchar(max), @ins_prcca_Sequence)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Commodity Attribute', @Action, 'prcca_Sequence', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcca_Publish
        IF  (  Update(prcca_Publish))
        BEGIN
            SET @OldValue =  @del_prcca_Publish
            SET @NewValue =  @ins_prcca_Publish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Commodity Attribute', @Action, 'prcca_Publish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcca_PublishWithGM
        IF  (  Update(prcca_PublishWithGM))
        BEGIN
            SET @OldValue =  @del_prcca_PublishWithGM
            SET @NewValue =  @ins_prcca_PublishWithGM
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Commodity Attribute', @Action, 'prcca_PublishWithGM', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcca_PublishedDisplay
        IF  (  Update(prcca_PublishedDisplay))
        BEGIN
            SET @OldValue =  @del_prcca_PublishedDisplay
            SET @NewValue =  @ins_prcca_PublishedDisplay
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Commodity Attribute', @Action, 'prcca_PublishedDisplay', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyCommodityAttribute SET 
        PRCompanyCommodityAttribute.prcca_CompanyCommodityAttributeId=i.prcca_CompanyCommodityAttributeId, 
        PRCompanyCommodityAttribute.prcca_Deleted=i.prcca_Deleted, 
        PRCompanyCommodityAttribute.prcca_WorkflowId=i.prcca_WorkflowId, 
        PRCompanyCommodityAttribute.prcca_Secterr=i.prcca_Secterr, 
        PRCompanyCommodityAttribute.prcca_CreatedBy=i.prcca_CreatedBy, 
        PRCompanyCommodityAttribute.prcca_CreatedDate=dbo.ufn_GetAccpacDate(i.prcca_CreatedDate), 
        PRCompanyCommodityAttribute.prcca_UpdatedBy=i.prcca_UpdatedBy, 
        PRCompanyCommodityAttribute.prcca_UpdatedDate=dbo.ufn_GetAccpacDate(i.prcca_UpdatedDate), 
        PRCompanyCommodityAttribute.prcca_TimeStamp=dbo.ufn_GetAccpacDate(i.prcca_TimeStamp), 
        PRCompanyCommodityAttribute.prcca_CompanyId=i.prcca_CompanyId, 
        PRCompanyCommodityAttribute.prcca_CommodityId=i.prcca_CommodityId, 
        PRCompanyCommodityAttribute.prcca_AttributeId=i.prcca_AttributeId, 
        PRCompanyCommodityAttribute.prcca_Sequence=i.prcca_Sequence, 
        PRCompanyCommodityAttribute.prcca_Publish=i.prcca_Publish, 
        PRCompanyCommodityAttribute.prcca_PublishWithGM=i.prcca_PublishWithGM, 
        PRCompanyCommodityAttribute.prcca_PublishedDisplay=i.prcca_PublishedDisplay, 
        PRCompanyCommodityAttribute.prcca_GrowingMethodId=i.prcca_GrowingMethodId
        FROM inserted i 
          INNER JOIN PRCompanyCommodityAttribute ON i.prcca_CompanyCommodityAttributeId=PRCompanyCommodityAttribute.prcca_CompanyCommodityAttributeId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyCommodityAttribute_insdel
 * 
 * Table:  PRCompanyCommodityAttribute
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyCommodityAttribute_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyCommodityAttribute_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyCommodityAttribute_insdel
ON PRCompanyCommodityAttribute
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prcca_CompanyCommodityAttributeId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prcca_CompanyID int, prcca_CommodityId int, prcca_AttributeId int, prcca_GrowingMethodId int)
    INSERT INTO @ProcessTable
        SELECT 'Insert',prcca_CompanyID,prcca_CommodityId,prcca_AttributeId,prcca_GrowingMethodId
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prcca_CompanyID,prcca_CommodityId,prcca_AttributeId,prcca_GrowingMethodId
        FROM Deleted


    Declare @prcca_CommodityId int
    Declare @prcca_AttributeId int
    Declare @prcca_GrowingMethodId int

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prcca_CompanyID,prcca_CommodityId,prcca_AttributeId,prcca_GrowingMethodId
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prcca_CommodityId,@prcca_AttributeId,@prcca_GrowingMethodId
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_CompanyId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Commodity Attribute ' + convert(varchar,@prcca_CompanyCommodityAttributeId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prcm_Name FROM PRCommodity WITH (NOLOCK) 
                WHERE prcm_CommodityId = @prcca_CommodityId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcca_CommodityId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prat_Name FROM PRAttribute WITH (NOLOCK) 
                WHERE prat_AttributeId = @prcca_AttributeId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcca_AttributeId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prat_Name FROM PRAttribute WITH (NOLOCK) 
                WHERE prat_AttributeId = @prcca_GrowingMethodId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcca_GrowingMethodId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Commodity Attribute', @Action, 
            'prcm_Name,prat_Name,prat_Name', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prcca_CommodityId,@prcca_AttributeId,@prcca_GrowingMethodId
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyRegion_ioupd
 * 
 * Table:  PRCompanyRegion
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyRegion_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyRegion_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyRegion_ioupd
ON PRCompanyRegion
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prcd_CompanyRegionId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prcd_CompanyID, @UserId = i.prcd_UpdatedBy, @prcd_CompanyRegionId = i.prcd_CompanyRegionId
        FROM Inserted i
        INNER JOIN deleted d ON i.prcd_CompanyRegionId = d.prcd_CompanyRegionId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prcd_Type) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Region ' + convert(varchar,@prcd_CompanyRegionId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prcd_Type nvarchar(5), @del_prcd_Type nvarchar(5)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prcd_Type = i.prcd_Type, @del_prcd_Type = d.prcd_Type
        FROM Inserted i
        INNER JOIN deleted d ON i.prcd_CompanyRegionId = d.prcd_CompanyRegionId

        -- prcd_Type
        IF  (  Update(prcd_Type))
        BEGIN
            SET @OldValue =  @del_prcd_Type
            SET @NewValue =  @ins_prcd_Type
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Region', @Action, 'prcd_Type', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyRegion SET 
        PRCompanyRegion.prcd_CompanyRegionId=i.prcd_CompanyRegionId, 
        PRCompanyRegion.prcd_CreatedBy=i.prcd_CreatedBy, 
        PRCompanyRegion.prcd_CreatedDate=dbo.ufn_GetAccpacDate(i.prcd_CreatedDate), 
        PRCompanyRegion.prcd_UpdatedBy=i.prcd_UpdatedBy, 
        PRCompanyRegion.prcd_UpdatedDate=dbo.ufn_GetAccpacDate(i.prcd_UpdatedDate), 
        PRCompanyRegion.prcd_TimeStamp=dbo.ufn_GetAccpacDate(i.prcd_TimeStamp), 
        PRCompanyRegion.prcd_Deleted=i.prcd_Deleted, 
        PRCompanyRegion.prcd_WorkflowId=i.prcd_WorkflowId, 
        PRCompanyRegion.prcd_Secterr=i.prcd_Secterr, 
        PRCompanyRegion.prcd_CompanyId=i.prcd_CompanyId, 
        PRCompanyRegion.prcd_RegionId=i.prcd_RegionId, 
        PRCompanyRegion.prcd_Type=i.prcd_Type
        FROM inserted i 
          INNER JOIN PRCompanyRegion ON i.prcd_CompanyRegionId=PRCompanyRegion.prcd_CompanyRegionId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyStockExchange_ioupd
 * 
 * Table:  PRCompanyStockExchange
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyStockExchange_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyStockExchange_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyStockExchange_ioupd
ON PRCompanyStockExchange
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prc4_CompanyStockExchangeId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prc4_CompanyID, @UserId = i.prc4_UpdatedBy, @prc4_CompanyStockExchangeId = i.prc4_CompanyStockExchangeId
        FROM Inserted i
        INNER JOIN deleted d ON i.prc4_CompanyStockExchangeId = d.prc4_CompanyStockExchangeId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prc4_Symbol1) OR
        Update (prc4_Symbol2) OR
        Update (prc4_Symbol3) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Exchange ' + convert(varchar,@prc4_CompanyStockExchangeId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prc4_Symbol1 nvarchar(10), @del_prc4_Symbol1 nvarchar(10)
        Declare @ins_prc4_Symbol2 nvarchar(10), @del_prc4_Symbol2 nvarchar(10)
        Declare @ins_prc4_Symbol3 nvarchar(10), @del_prc4_Symbol3 nvarchar(10)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prc4_Symbol1 = i.prc4_Symbol1, @del_prc4_Symbol1 = d.prc4_Symbol1,
            @ins_prc4_Symbol2 = i.prc4_Symbol2, @del_prc4_Symbol2 = d.prc4_Symbol2,
            @ins_prc4_Symbol3 = i.prc4_Symbol3, @del_prc4_Symbol3 = d.prc4_Symbol3
        FROM Inserted i
        INNER JOIN deleted d ON i.prc4_CompanyStockExchangeId = d.prc4_CompanyStockExchangeId

        -- prc4_Symbol1
        IF  (  Update(prc4_Symbol1))
        BEGIN
            SET @OldValue =  @del_prc4_Symbol1
            SET @NewValue =  @ins_prc4_Symbol1
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Exchange', @Action, 'prc4_Symbol1', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc4_Symbol2
        IF  (  Update(prc4_Symbol2))
        BEGIN
            SET @OldValue =  @del_prc4_Symbol2
            SET @NewValue =  @ins_prc4_Symbol2
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Exchange', @Action, 'prc4_Symbol2', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prc4_Symbol3
        IF  (  Update(prc4_Symbol3))
        BEGIN
            SET @OldValue =  @del_prc4_Symbol3
            SET @NewValue =  @ins_prc4_Symbol3
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Exchange', @Action, 'prc4_Symbol3', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyStockExchange SET 
        PRCompanyStockExchange.prc4_CompanyStockExchangeId=i.prc4_CompanyStockExchangeId, 
        PRCompanyStockExchange.prc4_CreatedBy=i.prc4_CreatedBy, 
        PRCompanyStockExchange.prc4_CreatedDate=dbo.ufn_GetAccpacDate(i.prc4_CreatedDate), 
        PRCompanyStockExchange.prc4_UpdatedBy=i.prc4_UpdatedBy, 
        PRCompanyStockExchange.prc4_UpdatedDate=dbo.ufn_GetAccpacDate(i.prc4_UpdatedDate), 
        PRCompanyStockExchange.prc4_TimeStamp=dbo.ufn_GetAccpacDate(i.prc4_TimeStamp), 
        PRCompanyStockExchange.prc4_Deleted=i.prc4_Deleted, 
        PRCompanyStockExchange.prc4_WorkflowId=i.prc4_WorkflowId, 
        PRCompanyStockExchange.prc4_Secterr=i.prc4_Secterr, 
        PRCompanyStockExchange.prc4_CompanyId=i.prc4_CompanyId, 
        PRCompanyStockExchange.prc4_StockExchangeId=i.prc4_StockExchangeId, 
        PRCompanyStockExchange.prc4_Symbol1=i.prc4_Symbol1, 
        PRCompanyStockExchange.prc4_Symbol2=i.prc4_Symbol2, 
        PRCompanyStockExchange.prc4_Symbol3=i.prc4_Symbol3
        FROM inserted i 
          INNER JOIN PRCompanyStockExchange ON i.prc4_CompanyStockExchangeId=PRCompanyStockExchange.prc4_CompanyStockExchangeId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyStockExchange_insdel
 * 
 * Table:  PRCompanyStockExchange
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyStockExchange_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyStockExchange_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyStockExchange_insdel
ON PRCompanyStockExchange
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prc4_CompanyStockExchangeId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prc4_CompanyID int, prc4_StockExchangeId int, prc4_Symbol1 nvarchar(10))
    INSERT INTO @ProcessTable
        SELECT 'Insert',prc4_CompanyID,prc4_StockExchangeId,prc4_Symbol1
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prc4_CompanyID,prc4_StockExchangeId,prc4_Symbol1
        FROM Deleted


    Declare @prc4_StockExchangeId int
    Declare @prc4_Symbol1 nvarchar(10)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prc4_CompanyID,prc4_StockExchangeId,prc4_Symbol1
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prc4_StockExchangeId,@prc4_Symbol1
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_CompanyId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Exchange ' + convert(varchar,@prc4_CompanyStockExchangeId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prex_Name FROM PRStockExchange WITH (NOLOCK) 
                WHERE prex_StockExchangeId = @prc4_StockExchangeId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prc4_StockExchangeId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        SET @NewValueTemp = convert(varchar(50), @prc4_Symbol1)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Exchange', @Action, 
            'prex_Name,prc4_Symbol1', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prc4_StockExchangeId,@prc4_Symbol1
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyTerminalMarket_insdel
 * 
 * Table:  PRCompanyTerminalMarket
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyTerminalMarket_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyTerminalMarket_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyTerminalMarket_insdel
ON PRCompanyTerminalMarket
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prct_CompanyTerminalMarketId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prct_CompanyID int, prct_TerminalMarketId int)
    INSERT INTO @ProcessTable
        SELECT 'Insert',prct_CompanyID,prct_TerminalMarketId
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prct_CompanyID,prct_TerminalMarketId
        FROM Deleted


    Declare @prct_TerminalMarketId int

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prct_CompanyID,prct_TerminalMarketId
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prct_TerminalMarketId
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_CompanyId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Terminal Market ' + convert(varchar,@prct_CompanyTerminalMarketId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prtm_FullMarketName FROM PRTerminalMarket WITH (NOLOCK) 
                WHERE prtm_TerminalMarketId = @prct_TerminalMarketId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prct_TerminalMarketId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Terminal Market', @Action, 
            'prtm_FullMarketName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prct_TerminalMarketId
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyLicense_ioupd
 * 
 * Table:  PRCompanyLicense
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyLicense_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyLicense_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyLicense_ioupd
ON PRCompanyLicense
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prli_CompanyLicenseId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prli_CompanyID, @UserId = i.prli_UpdatedBy, @prli_CompanyLicenseId = i.prli_CompanyLicenseId
        FROM Inserted i
        INNER JOIN deleted d ON i.prli_CompanyLicenseId = d.prli_CompanyLicenseId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prli_Type) OR
        Update (prli_Number) OR
        Update (prli_Publish) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company License ' + convert(varchar,@prli_CompanyLicenseId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prli_Type nvarchar(40), @del_prli_Type nvarchar(40)
        Declare @ins_prli_Number nvarchar(34), @del_prli_Number nvarchar(34)
        Declare @ins_prli_Publish nchar(1), @del_prli_Publish nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prli_Type = i.prli_Type, @del_prli_Type = d.prli_Type,
            @ins_prli_Number = i.prli_Number, @del_prli_Number = d.prli_Number,
            @ins_prli_Publish = i.prli_Publish, @del_prli_Publish = d.prli_Publish
        FROM Inserted i
        INNER JOIN deleted d ON i.prli_CompanyLicenseId = d.prli_CompanyLicenseId

        -- prli_Type
        IF  (  Update(prli_Type))
        BEGIN
            SET @OldValue =  @del_prli_Type
            SET @NewValue =  @ins_prli_Type
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company License', @Action, 'prli_Type', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prli_Number
        IF  (  Update(prli_Number))
        BEGIN
            SET @OldValue =  @del_prli_Number
            SET @NewValue =  @ins_prli_Number
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company License', @Action, 'prli_Number', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prli_Publish
        IF  (  Update(prli_Publish))
        BEGIN
            SET @OldValue =  @del_prli_Publish
            SET @NewValue =  @ins_prli_Publish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company License', @Action, 'prli_Publish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyLicense SET 
        PRCompanyLicense.prli_CompanyLicenseId=i.prli_CompanyLicenseId, 
        PRCompanyLicense.prli_Deleted=i.prli_Deleted, 
        PRCompanyLicense.prli_WorkflowId=i.prli_WorkflowId, 
        PRCompanyLicense.prli_Secterr=i.prli_Secterr, 
        PRCompanyLicense.prli_CreatedBy=i.prli_CreatedBy, 
        PRCompanyLicense.prli_CreatedDate=dbo.ufn_GetAccpacDate(i.prli_CreatedDate), 
        PRCompanyLicense.prli_UpdatedBy=i.prli_UpdatedBy, 
        PRCompanyLicense.prli_UpdatedDate=dbo.ufn_GetAccpacDate(i.prli_UpdatedDate), 
        PRCompanyLicense.prli_TimeStamp=dbo.ufn_GetAccpacDate(i.prli_TimeStamp), 
        PRCompanyLicense.prli_CompanyId=i.prli_CompanyId, 
        PRCompanyLicense.prli_Type=i.prli_Type, 
        PRCompanyLicense.prli_Number=i.prli_Number, 
        PRCompanyLicense.prli_Publish=i.prli_Publish
        FROM inserted i 
          INNER JOIN PRCompanyLicense ON i.prli_CompanyLicenseId=PRCompanyLicense.prli_CompanyLicenseId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyLicense_insdel
 * 
 * Table:  PRCompanyLicense
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyLicense_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyLicense_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyLicense_insdel
ON PRCompanyLicense
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prli_CompanyLicenseId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prli_CompanyID int, prli_Type nvarchar(40), prli_Number nvarchar(34))
    INSERT INTO @ProcessTable
        SELECT 'Insert',prli_CompanyID,prli_Type,prli_Number
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prli_CompanyID,prli_Type,prli_Number
        FROM Deleted


    Declare @prli_Type nvarchar(40)
    Declare @prli_Number nvarchar(34)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prli_CompanyID,prli_Type,prli_Number
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prli_Type,@prli_Number
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_CompanyId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company License ' + convert(varchar,@prli_CompanyLicenseId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = convert(varchar(50), @prli_Type)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        SET @NewValueTemp = convert(varchar(50), @prli_Number)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company License', @Action, 
            'prli_Type,prli_Number', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prli_Type,@prli_Number
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyAlias_ioupd
 * 
 * Table:  PRCompanyAlias
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyAlias_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyAlias_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyAlias_ioupd
ON PRCompanyAlias
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @pral_CompanyAliasId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.pral_CompanyID, @UserId = i.pral_UpdatedBy, @pral_CompanyAliasId = i.pral_CompanyAliasId
        FROM Inserted i
        INNER JOIN deleted d ON i.pral_CompanyAliasId = d.pral_CompanyAliasId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (pral_Alias) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Alias ' + convert(varchar,@pral_CompanyAliasId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_pral_Alias nvarchar(104), @del_pral_Alias nvarchar(104)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_pral_Alias = i.pral_Alias, @del_pral_Alias = d.pral_Alias
        FROM Inserted i
        INNER JOIN deleted d ON i.pral_CompanyAliasId = d.pral_CompanyAliasId

        -- pral_Alias
        IF  (  Update(pral_Alias))
        BEGIN
            SET @OldValue =  @del_pral_Alias
            SET @NewValue =  @ins_pral_Alias
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Alias', @Action, 'pral_Alias', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyAlias SET 
        PRCompanyAlias.pral_CompanyAliasId=i.pral_CompanyAliasId, 
        PRCompanyAlias.pral_Deleted=i.pral_Deleted, 
        PRCompanyAlias.pral_WorkflowId=i.pral_WorkflowId, 
        PRCompanyAlias.pral_Secterr=i.pral_Secterr, 
        PRCompanyAlias.pral_CreatedBy=i.pral_CreatedBy, 
        PRCompanyAlias.pral_CreatedDate=dbo.ufn_GetAccpacDate(i.pral_CreatedDate), 
        PRCompanyAlias.pral_UpdatedBy=i.pral_UpdatedBy, 
        PRCompanyAlias.pral_UpdatedDate=dbo.ufn_GetAccpacDate(i.pral_UpdatedDate), 
        PRCompanyAlias.pral_TimeStamp=dbo.ufn_GetAccpacDate(i.pral_TimeStamp), 
        PRCompanyAlias.pral_CompanyId=i.pral_CompanyId, 
        PRCompanyAlias.pral_Alias=i.pral_Alias, 
        PRCompanyAlias.pral_NameAlphaOnly=i.pral_NameAlphaOnly
        FROM inserted i 
          INNER JOIN PRCompanyAlias ON i.pral_CompanyAliasId=PRCompanyAlias.pral_CompanyAliasId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyAlias_insdel
 * 
 * Table:  PRCompanyAlias
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyAlias_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyAlias_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyAlias_insdel
ON PRCompanyAlias
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @pral_CompanyAliasId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), pral_CompanyID int, pral_Alias nvarchar(104))
    INSERT INTO @ProcessTable
        SELECT 'Insert',pral_CompanyID,pral_Alias
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',pral_CompanyID,pral_Alias
        FROM Deleted


    Declare @pral_Alias nvarchar(104)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, pral_CompanyID,pral_Alias
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@pral_Alias
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_CompanyId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Alias ' + convert(varchar,@pral_CompanyAliasId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = convert(varchar(50), @pral_Alias)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Alias', @Action, 
            'pral_Alias', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@pral_Alias
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRRating_ioupd
 * 
 * Table:  PRRating
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRRating_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRRating_ioupd]
GO

CREATE TRIGGER dbo.trg_PRRating_ioupd
ON PRRating
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prra_RatingId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prra_CompanyID, @UserId = i.prra_UpdatedBy, @prra_RatingId = i.prra_RatingId
        FROM Inserted i
        INNER JOIN deleted d ON i.prra_RatingId = d.prra_RatingId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_CompanyId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prra_Date) OR
        Update (prra_Current) OR
        Update (prra_CreditWorthId) OR
        Update (prra_IntegrityId) OR
        Update (prra_PayRatingId) OR
        Update (prra_InternalAnalysis) OR
        Update (prra_PublishedAnalysis) OR
        Update (prra_UpgradeDowngrade) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Rating ' + convert(varchar,@prra_RatingId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prra_Date datetime, @del_prra_Date datetime
        Declare @ins_prra_Current nchar(1), @del_prra_Current nchar(1)
        Declare @ins_prra_CreditWorthId int, @del_prra_CreditWorthId int
        Declare @ins_prra_IntegrityId int, @del_prra_IntegrityId int
        Declare @ins_prra_PayRatingId int, @del_prra_PayRatingId int
        Declare @ins_prra_InternalAnalysis varchar(max), @del_prra_InternalAnalysis varchar(max)
        Declare @ins_prra_PublishedAnalysis varchar(max), @del_prra_PublishedAnalysis varchar(max)
        Declare @ins_prra_UpgradeDowngrade nvarchar(40), @del_prra_UpgradeDowngrade nvarchar(40)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prra_Date = i.prra_Date, @del_prra_Date = d.prra_Date,
            @ins_prra_Current = i.prra_Current, @del_prra_Current = d.prra_Current,
            @ins_prra_CreditWorthId = i.prra_CreditWorthId, @del_prra_CreditWorthId = d.prra_CreditWorthId,
            @ins_prra_IntegrityId = i.prra_IntegrityId, @del_prra_IntegrityId = d.prra_IntegrityId,
            @ins_prra_PayRatingId = i.prra_PayRatingId, @del_prra_PayRatingId = d.prra_PayRatingId,
            @ins_prra_InternalAnalysis = i.prra_InternalAnalysis, @del_prra_InternalAnalysis = d.prra_InternalAnalysis,
            @ins_prra_PublishedAnalysis = i.prra_PublishedAnalysis, @del_prra_PublishedAnalysis = d.prra_PublishedAnalysis,
            @ins_prra_UpgradeDowngrade = i.prra_UpgradeDowngrade, @del_prra_UpgradeDowngrade = d.prra_UpgradeDowngrade
        FROM Inserted i
        INNER JOIN deleted d ON i.prra_RatingId = d.prra_RatingId

        -- prra_Date
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prra_Date, @ins_prra_Date) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prra_Date IS NOT NULL AND convert(varchar,@del_prra_Date,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_prra_Date)
            IF (@ins_prra_Date IS NOT NULL AND convert(varchar,@ins_prra_Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_prra_Date)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_Date', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prra_Current
        IF  (  Update(prra_Current))
        BEGIN
            SET @OldValue =  @del_prra_Current
            SET @NewValue =  @ins_prra_Current
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_Current', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prra_CreditWorthId
        IF  (  Update(prra_CreditWorthId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prcw_Name FROM PRCreditWorthRating WITH (NOLOCK) 
                WHERE prcw_CreditWorthRatingId = @ins_prra_CreditWorthId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_prra_CreditWorthId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prcw_Name FROM PRCreditWorthRating WITH (NOLOCK) 
                WHERE prcw_CreditWorthRatingId = @del_prra_CreditWorthId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_prra_CreditWorthId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_CreditWorthId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prra_IntegrityId
        IF  (  Update(prra_IntegrityId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prin_Name FROM PRIntegrityRating WITH (NOLOCK) 
                WHERE prin_IntegrityRatingId = @ins_prra_IntegrityId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_prra_IntegrityId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prin_Name FROM PRIntegrityRating WITH (NOLOCK) 
                WHERE prin_IntegrityRatingId = @del_prra_IntegrityId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_prra_IntegrityId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_IntegrityId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prra_PayRatingId
        IF  (  Update(prra_PayRatingId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prpy_Name FROM PRPayRating WITH (NOLOCK) 
                WHERE prpy_PayRatingId = @ins_prra_PayRatingId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_prra_PayRatingId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prpy_Name FROM PRPayRating WITH (NOLOCK) 
                WHERE prpy_PayRatingId = @del_prra_PayRatingId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_prra_PayRatingId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_PayRatingId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prra_InternalAnalysis
        IF  (  Update(prra_InternalAnalysis))
        BEGIN
            SET @OldValue =  @del_prra_InternalAnalysis
            SET @NewValue =  @ins_prra_InternalAnalysis
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_InternalAnalysis', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prra_PublishedAnalysis
        IF  (  Update(prra_PublishedAnalysis))
        BEGIN
            SET @OldValue =  @del_prra_PublishedAnalysis
            SET @NewValue =  @ins_prra_PublishedAnalysis
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_PublishedAnalysis', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prra_UpgradeDowngrade
        IF  (  Update(prra_UpgradeDowngrade))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='prra_UpgradeDowngrade' AND capt_code = @ins_prra_UpgradeDowngrade
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prra_UpgradeDowngrade)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='prra_UpgradeDowngrade' AND capt_code = @del_prra_UpgradeDowngrade
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prra_UpgradeDowngrade)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_UpgradeDowngrade', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRRating SET 
        PRRating.prra_RatingId=i.prra_RatingId, 
        PRRating.prra_Deleted=i.prra_Deleted, 
        PRRating.prra_WorkflowId=i.prra_WorkflowId, 
        PRRating.prra_Secterr=i.prra_Secterr, 
        PRRating.prra_CreatedBy=i.prra_CreatedBy, 
        PRRating.prra_CreatedDate=dbo.ufn_GetAccpacDate(i.prra_CreatedDate), 
        PRRating.prra_UpdatedBy=i.prra_UpdatedBy, 
        PRRating.prra_UpdatedDate=dbo.ufn_GetAccpacDate(i.prra_UpdatedDate), 
        PRRating.prra_TimeStamp=dbo.ufn_GetAccpacDate(i.prra_TimeStamp), 
        PRRating.prra_CompanyId=i.prra_CompanyId, 
        PRRating.prra_Date=dbo.ufn_GetAccpacDate(i.prra_Date), 
        PRRating.prra_Current=i.prra_Current, 
        PRRating.prra_CreditWorthId=i.prra_CreditWorthId, 
        PRRating.prra_IntegrityId=i.prra_IntegrityId, 
        PRRating.prra_PayRatingId=i.prra_PayRatingId, 
        PRRating.prra_InternalAnalysis=i.prra_InternalAnalysis, 
        PRRating.prra_PublishedAnalysis=i.prra_PublishedAnalysis, 
        PRRating.prra_Rated=i.prra_Rated, 
        PRRating.prra_UpgradeDowngrade=i.prra_UpgradeDowngrade
        FROM inserted i 
          INNER JOIN PRRating ON i.prra_RatingId=PRRating.prra_RatingId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRRatingNumeralAssigned_insdel
 * 
 * Table:  PRRatingNumeralAssigned
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRRatingNumeralAssigned_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRRatingNumeralAssigned_insdel]
GO

CREATE TRIGGER dbo.trg_PRRatingNumeralAssigned_insdel
ON PRRatingNumeralAssigned
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @pran_RatingNumeralAssignedId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), pran_RatingId int, pran_RatingNumeralId int)
    INSERT INTO @ProcessTable
        SELECT 'Insert',pran_RatingId,pran_RatingNumeralId
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',pran_RatingId,pran_RatingNumeralId
        FROM Deleted


    Declare @pran_RatingNumeralId int

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, pran_RatingId,pran_RatingNumeralId
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@pran_RatingNumeralId
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_CompanyId = (SELECT prra_CompanyId FROM PRRating WHERE prra_RatingId = @TrxKeyId)
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Assigned Rating Numeral ' + convert(varchar,@pran_RatingNumeralAssignedId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prrn_Name FROM PRRatingNumeral WITH (NOLOCK) 
                WHERE prrn_RatingNumeralId = @pran_RatingNumeralId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @pran_RatingNumeralId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Assigned Rating Numeral', @Action, 
            'prrn_Name', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@pran_RatingNumeralId
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_Person_ioupd
 * 
 * Table:  Person
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Person_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Person_ioupd]
GO

CREATE TRIGGER dbo.trg_Person_ioupd
ON Person
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @pers_PersonId int
    Declare @UserId int
    Declare @PersonId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.pers_PersonId, @UserId = i.pers_UpdatedBy, @pers_PersonId = i.pers_PersonId
        FROM Inserted i
        INNER JOIN deleted d ON i.pers_PersonId = d.pers_PersonId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_PersonId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (Pers_PrimaryAddressId) OR
        Update (Pers_Salutation) OR
        Update (Pers_FirstName) OR
        Update (Pers_LastName) OR
        Update (Pers_MiddleName) OR
        Update (Pers_Suffix) OR
        Update (Pers_Gender) OR
        Update (Pers_Status) OR
        Update (Pers_Source) OR
        Update (pers_PRYearBorn) OR
        Update (pers_PRDeathDate) OR
        Update (pers_PRLanguageSpoken) OR
        Update (pers_PRPaternalLastName) OR
        Update (pers_PRMaternalLastName) OR
        Update (pers_PRNickname1) OR
        Update (pers_PRNickname2) OR
        Update (pers_PRMaidenName) OR
        Update (pers_PRIndustryStartDate) OR
        Update (pers_PRNotes) OR
        Update (pers_PRDefaultEmailId) OR
        Update (pers_PRUnconfirmed) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Person ' + convert(varchar,@pers_PersonId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_Pers_PrimaryAddressId int, @del_Pers_PrimaryAddressId int
        Declare @ins_Pers_Salutation nchar(10), @del_Pers_Salutation nchar(10)
        Declare @ins_Pers_FirstName nchar(30), @del_Pers_FirstName nchar(30)
        Declare @ins_Pers_LastName nchar(40), @del_Pers_LastName nchar(40)
        Declare @ins_Pers_MiddleName nchar(30), @del_Pers_MiddleName nchar(30)
        Declare @ins_Pers_Suffix nchar(20), @del_Pers_Suffix nchar(20)
        Declare @ins_Pers_Gender nchar(6), @del_Pers_Gender nchar(6)
        Declare @ins_Pers_Status nchar(40), @del_Pers_Status nchar(40)
        Declare @ins_Pers_Source nchar(40), @del_Pers_Source nchar(40)
        Declare @ins_pers_PRYearBorn nvarchar(10), @del_pers_PRYearBorn nvarchar(10)
        Declare @ins_pers_PRDeathDate nvarchar(10), @del_pers_PRDeathDate nvarchar(10)
        Declare @ins_pers_PRLanguageSpoken nvarchar(255), @del_pers_PRLanguageSpoken nvarchar(255)
        Declare @ins_pers_PRPaternalLastName nvarchar(15), @del_pers_PRPaternalLastName nvarchar(15)
        Declare @ins_pers_PRMaternalLastName nvarchar(15), @del_pers_PRMaternalLastName nvarchar(15)
        Declare @ins_pers_PRNickname1 nvarchar(15), @del_pers_PRNickname1 nvarchar(15)
        Declare @ins_pers_PRNickname2 nvarchar(15), @del_pers_PRNickname2 nvarchar(15)
        Declare @ins_pers_PRMaidenName nvarchar(20), @del_pers_PRMaidenName nvarchar(20)
        Declare @ins_pers_PRIndustryStartDate nvarchar(10), @del_pers_PRIndustryStartDate nvarchar(10)
        Declare @ins_pers_PRNotes varchar(max), @del_pers_PRNotes varchar(max)
        Declare @ins_pers_PRDefaultEmailId int, @del_pers_PRDefaultEmailId int
        Declare @ins_pers_PRUnconfirmed nchar(1), @del_pers_PRUnconfirmed nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_Pers_PrimaryAddressId = i.Pers_PrimaryAddressId, @del_Pers_PrimaryAddressId = d.Pers_PrimaryAddressId,
            @ins_Pers_Salutation = i.Pers_Salutation, @del_Pers_Salutation = d.Pers_Salutation,
            @ins_Pers_FirstName = i.Pers_FirstName, @del_Pers_FirstName = d.Pers_FirstName,
            @ins_Pers_LastName = i.Pers_LastName, @del_Pers_LastName = d.Pers_LastName,
            @ins_Pers_MiddleName = i.Pers_MiddleName, @del_Pers_MiddleName = d.Pers_MiddleName,
            @ins_Pers_Suffix = i.Pers_Suffix, @del_Pers_Suffix = d.Pers_Suffix,
            @ins_Pers_Gender = i.Pers_Gender, @del_Pers_Gender = d.Pers_Gender,
            @ins_Pers_Status = i.Pers_Status, @del_Pers_Status = d.Pers_Status,
            @ins_Pers_Source = i.Pers_Source, @del_Pers_Source = d.Pers_Source,
            @ins_pers_PRYearBorn = i.pers_PRYearBorn, @del_pers_PRYearBorn = d.pers_PRYearBorn,
            @ins_pers_PRDeathDate = i.pers_PRDeathDate, @del_pers_PRDeathDate = d.pers_PRDeathDate,
            @ins_pers_PRLanguageSpoken = i.pers_PRLanguageSpoken, @del_pers_PRLanguageSpoken = d.pers_PRLanguageSpoken,
            @ins_pers_PRPaternalLastName = i.pers_PRPaternalLastName, @del_pers_PRPaternalLastName = d.pers_PRPaternalLastName,
            @ins_pers_PRMaternalLastName = i.pers_PRMaternalLastName, @del_pers_PRMaternalLastName = d.pers_PRMaternalLastName,
            @ins_pers_PRNickname1 = i.pers_PRNickname1, @del_pers_PRNickname1 = d.pers_PRNickname1,
            @ins_pers_PRNickname2 = i.pers_PRNickname2, @del_pers_PRNickname2 = d.pers_PRNickname2,
            @ins_pers_PRMaidenName = i.pers_PRMaidenName, @del_pers_PRMaidenName = d.pers_PRMaidenName,
            @ins_pers_PRIndustryStartDate = i.pers_PRIndustryStartDate, @del_pers_PRIndustryStartDate = d.pers_PRIndustryStartDate,
            @ins_pers_PRNotes = i.pers_PRNotes, @del_pers_PRNotes = d.pers_PRNotes,
            @ins_pers_PRDefaultEmailId = i.pers_PRDefaultEmailId, @del_pers_PRDefaultEmailId = d.pers_PRDefaultEmailId,
            @ins_pers_PRUnconfirmed = i.pers_PRUnconfirmed, @del_pers_PRUnconfirmed = d.pers_PRUnconfirmed
        FROM Inserted i
        INNER JOIN deleted d ON i.pers_PersonId = d.pers_PersonId

        -- Pers_PrimaryAddressId
        IF  (  Update(Pers_PrimaryAddressId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = addr_Address1 FROM Address WITH (NOLOCK) 
                WHERE addr_AddressId = @ins_Pers_PrimaryAddressId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_Pers_PrimaryAddressId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = addr_Address1 FROM Address WITH (NOLOCK) 
                WHERE addr_AddressId = @del_Pers_PrimaryAddressId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_Pers_PrimaryAddressId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'Pers_PrimaryAddressId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Pers_Salutation
        IF  (  Update(Pers_Salutation))
        BEGIN
            SET @OldValue =  @del_Pers_Salutation
            SET @NewValue =  @ins_Pers_Salutation
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'Pers_Salutation', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Pers_FirstName
        IF  (  Update(Pers_FirstName))
        BEGIN
            SET @OldValue =  @del_Pers_FirstName
            SET @NewValue =  @ins_Pers_FirstName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'Pers_FirstName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Pers_LastName
        IF  (  Update(Pers_LastName))
        BEGIN
            SET @OldValue =  @del_Pers_LastName
            SET @NewValue =  @ins_Pers_LastName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'Pers_LastName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Pers_MiddleName
        IF  (  Update(Pers_MiddleName))
        BEGIN
            SET @OldValue =  @del_Pers_MiddleName
            SET @NewValue =  @ins_Pers_MiddleName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'Pers_MiddleName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Pers_Suffix
        IF  (  Update(Pers_Suffix))
        BEGIN
            SET @OldValue =  @del_Pers_Suffix
            SET @NewValue =  @ins_Pers_Suffix
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'Pers_Suffix', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Pers_Gender
        IF  (  Update(Pers_Gender))
        BEGIN
            SET @OldValue =  @del_Pers_Gender
            SET @NewValue =  @ins_Pers_Gender
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'Pers_Gender', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Pers_Status
        IF  (  Update(Pers_Status))
        BEGIN
            SET @OldValue =  @del_Pers_Status
            SET @NewValue =  @ins_Pers_Status
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'Pers_Status', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Pers_Source
        IF  (  Update(Pers_Source))
        BEGIN
            SET @OldValue =  @del_Pers_Source
            SET @NewValue =  @ins_Pers_Source
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'Pers_Source', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRYearBorn
        IF  (  Update(pers_PRYearBorn))
        BEGIN
            SET @OldValue =  @del_pers_PRYearBorn
            SET @NewValue =  @ins_pers_PRYearBorn
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRYearBorn', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRDeathDate
        IF  (  Update(pers_PRDeathDate))
        BEGIN
            SET @OldValue =  @del_pers_PRDeathDate
            SET @NewValue =  @ins_pers_PRDeathDate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRDeathDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRLanguageSpoken
        IF  (  Update(pers_PRLanguageSpoken))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='pers_PRLanguageSpoken' AND capt_code = @ins_pers_PRLanguageSpoken
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_pers_PRLanguageSpoken)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK) 
                WHERE capt_family='pers_PRLanguageSpoken' AND capt_code = @del_pers_PRLanguageSpoken
            SET @OldValue = COALESCE(@NewValueTemp,  @del_pers_PRLanguageSpoken)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRLanguageSpoken', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRPaternalLastName
        IF  (  Update(pers_PRPaternalLastName))
        BEGIN
            SET @OldValue =  @del_pers_PRPaternalLastName
            SET @NewValue =  @ins_pers_PRPaternalLastName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRPaternalLastName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRMaternalLastName
        IF  (  Update(pers_PRMaternalLastName))
        BEGIN
            SET @OldValue =  @del_pers_PRMaternalLastName
            SET @NewValue =  @ins_pers_PRMaternalLastName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRMaternalLastName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRNickname1
        IF  (  Update(pers_PRNickname1))
        BEGIN
            SET @OldValue =  @del_pers_PRNickname1
            SET @NewValue =  @ins_pers_PRNickname1
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRNickname1', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRNickname2
        IF  (  Update(pers_PRNickname2))
        BEGIN
            SET @OldValue =  @del_pers_PRNickname2
            SET @NewValue =  @ins_pers_PRNickname2
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRNickname2', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRMaidenName
        IF  (  Update(pers_PRMaidenName))
        BEGIN
            SET @OldValue =  @del_pers_PRMaidenName
            SET @NewValue =  @ins_pers_PRMaidenName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRMaidenName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRIndustryStartDate
        IF  (  Update(pers_PRIndustryStartDate))
        BEGIN
            SET @OldValue =  @del_pers_PRIndustryStartDate
            SET @NewValue =  @ins_pers_PRIndustryStartDate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRIndustryStartDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRNotes
        IF  (  Update(pers_PRNotes))
        BEGIN
            SET @OldValue =  @del_pers_PRNotes
            SET @NewValue =  @ins_pers_PRNotes
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRNotes', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRDefaultEmailId
        IF  (  Update(pers_PRDefaultEmailId))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_pers_PRDefaultEmailId)
            SET @NewValue =  convert(varchar(max), @ins_pers_PRDefaultEmailId)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRDefaultEmailId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- pers_PRUnconfirmed
        IF  (  Update(pers_PRUnconfirmed))
        BEGIN
            SET @OldValue =  @del_pers_PRUnconfirmed
            SET @NewValue =  @ins_pers_PRUnconfirmed
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRUnconfirmed', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE Person SET 
        Person.Pers_PersonId=i.Pers_PersonId, 
        Person.Pers_CompanyId=i.Pers_CompanyId, 
        Person.Pers_PrimaryAddressId=i.Pers_PrimaryAddressId, 
        Person.Pers_PrimaryUserId=i.Pers_PrimaryUserId, 
        Person.Pers_Salutation=i.Pers_Salutation, 
        Person.Pers_FirstName=i.Pers_FirstName, 
        Person.Pers_LastName=i.Pers_LastName, 
        Person.Pers_MiddleName=i.Pers_MiddleName, 
        Person.Pers_Suffix=i.Pers_Suffix, 
        Person.Pers_Gender=i.Pers_Gender, 
        Person.Pers_Title=i.Pers_Title, 
        Person.Pers_TitleCode=i.Pers_TitleCode, 
        Person.Pers_Department=i.Pers_Department, 
        Person.Pers_Status=i.Pers_Status, 
        Person.Pers_Source=i.Pers_Source, 
        Person.Pers_Territory=i.Pers_Territory, 
        Person.Pers_WebSite=i.Pers_WebSite, 
        Person.Pers_MailRestriction=i.Pers_MailRestriction, 
        Person.Pers_CreatedBy=i.Pers_CreatedBy, 
        Person.Pers_CreatedDate=dbo.ufn_GetAccpacDate(i.Pers_CreatedDate), 
        Person.Pers_UpdatedBy=i.Pers_UpdatedBy, 
        Person.Pers_UpdatedDate=dbo.ufn_GetAccpacDate(i.Pers_UpdatedDate), 
        Person.Pers_TimeStamp=dbo.ufn_GetAccpacDate(i.Pers_TimeStamp), 
        Person.Pers_Deleted=i.Pers_Deleted, 
        Person.Pers_LibraryDir=i.Pers_LibraryDir, 
        Person.Pers_SegmentID=i.Pers_SegmentID, 
        Person.Pers_ChannelID=i.Pers_ChannelID, 
        Person.Pers_UploadDate=dbo.ufn_GetAccpacDate(i.Pers_UploadDate), 
        Person.pers_SecTerr=i.pers_SecTerr, 
        Person.Pers_WorkflowId=i.Pers_WorkflowId, 
        Person.pers_PRYearBorn=i.pers_PRYearBorn, 
        Person.pers_PRDeathDate=i.pers_PRDeathDate, 
        Person.pers_PRLanguageSpoken=i.pers_PRLanguageSpoken, 
        Person.pers_PRPaternalLastName=i.pers_PRPaternalLastName, 
        Person.pers_PRMaternalLastName=i.pers_PRMaternalLastName, 
        Person.pers_PRNickname1=i.pers_PRNickname1, 
        Person.pers_PRNickname2=i.pers_PRNickname2, 
        Person.pers_PRMaidenName=i.pers_PRMaidenName, 
        Person.pers_PRIndustryStartDate=i.pers_PRIndustryStartDate, 
        Person.pers_PRNotes=i.pers_PRNotes, 
        Person.pers_PRDefaultEmailId=i.pers_PRDefaultEmailId, 
        Person.pers_PRUnconfirmed=i.pers_PRUnconfirmed, 
        Person.pers_PRLinkedInProfile=i.pers_PRLinkedInProfile, 
        Person.pers_FirstNameAlphaOnly=i.pers_FirstNameAlphaOnly, 
        Person.pers_LastNameAlphaOnly=i.pers_LastNameAlphaOnly, 
        Person.pers_PRLocalSource=i.pers_PRLocalSource
        FROM inserted i 
          INNER JOIN Person ON i.pers_PersonId=Person.pers_PersonId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRPersonBackground_ioupd
 * 
 * Table:  PRPersonBackground
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRPersonBackground_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRPersonBackground_ioupd]
GO

CREATE TRIGGER dbo.trg_PRPersonBackground_ioupd
ON PRPersonBackground
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prba_PersonBackgroundId int
    Declare @UserId int
    Declare @PersonId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prba_PersonId, @UserId = i.prba_UpdatedBy, @prba_PersonBackgroundId = i.prba_PersonBackgroundId
        FROM Inserted i
        INNER JOIN deleted d ON i.prba_PersonBackgroundId = d.prba_PersonBackgroundId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_PersonId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prba_StartDate) OR
        Update (prba_EndDate) OR
        Update (prba_Company) OR
        Update (prba_Title) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Background ' + convert(varchar,@prba_PersonBackgroundId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prba_StartDate nvarchar(50), @del_prba_StartDate nvarchar(50)
        Declare @ins_prba_EndDate nvarchar(50), @del_prba_EndDate nvarchar(50)
        Declare @ins_prba_Company nvarchar(500), @del_prba_Company nvarchar(500)
        Declare @ins_prba_Title nvarchar(50), @del_prba_Title nvarchar(50)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prba_StartDate = i.prba_StartDate, @del_prba_StartDate = d.prba_StartDate,
            @ins_prba_EndDate = i.prba_EndDate, @del_prba_EndDate = d.prba_EndDate,
            @ins_prba_Company = i.prba_Company, @del_prba_Company = d.prba_Company,
            @ins_prba_Title = i.prba_Title, @del_prba_Title = d.prba_Title
        FROM Inserted i
        INNER JOIN deleted d ON i.prba_PersonBackgroundId = d.prba_PersonBackgroundId

        -- prba_StartDate
        IF  (  Update(prba_StartDate))
        BEGIN
            SET @OldValue =  @del_prba_StartDate
            SET @NewValue =  @ins_prba_StartDate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Background', @Action, 'prba_StartDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prba_EndDate
        IF  (  Update(prba_EndDate))
        BEGIN
            SET @OldValue =  @del_prba_EndDate
            SET @NewValue =  @ins_prba_EndDate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Background', @Action, 'prba_EndDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prba_Company
        IF  (  Update(prba_Company))
        BEGIN
            SET @OldValue =  @del_prba_Company
            SET @NewValue =  @ins_prba_Company
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Background', @Action, 'prba_Company', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prba_Title
        IF  (  Update(prba_Title))
        BEGIN
            SET @OldValue =  @del_prba_Title
            SET @NewValue =  @ins_prba_Title
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Background', @Action, 'prba_Title', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRPersonBackground SET 
        PRPersonBackground.prba_PersonBackgroundId=i.prba_PersonBackgroundId, 
        PRPersonBackground.prba_Deleted=i.prba_Deleted, 
        PRPersonBackground.prba_WorkflowId=i.prba_WorkflowId, 
        PRPersonBackground.prba_Secterr=i.prba_Secterr, 
        PRPersonBackground.prba_CreatedBy=i.prba_CreatedBy, 
        PRPersonBackground.prba_CreatedDate=dbo.ufn_GetAccpacDate(i.prba_CreatedDate), 
        PRPersonBackground.prba_UpdatedBy=i.prba_UpdatedBy, 
        PRPersonBackground.prba_UpdatedDate=dbo.ufn_GetAccpacDate(i.prba_UpdatedDate), 
        PRPersonBackground.prba_TimeStamp=dbo.ufn_GetAccpacDate(i.prba_TimeStamp), 
        PRPersonBackground.prba_PersonId=i.prba_PersonId, 
        PRPersonBackground.prba_StartDate=i.prba_StartDate, 
        PRPersonBackground.prba_EndDate=i.prba_EndDate, 
        PRPersonBackground.prba_Company=i.prba_Company, 
        PRPersonBackground.prba_Title=i.prba_Title
        FROM inserted i 
          INNER JOIN PRPersonBackground ON i.prba_PersonBackgroundId=PRPersonBackground.prba_PersonBackgroundId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRPersonBackground_insdel
 * 
 * Table:  PRPersonBackground
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRPersonBackground_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRPersonBackground_insdel]
GO

CREATE TRIGGER dbo.trg_PRPersonBackground_insdel
ON PRPersonBackground
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prba_PersonBackgroundId int
    Declare @UserId int
    Declare @PersonId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prba_PersonId int, prba_Company nvarchar(500), prba_Title nvarchar(50))
    INSERT INTO @ProcessTable
        SELECT 'Insert',prba_PersonId,prba_Company,prba_Title
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prba_PersonId,prba_Company,prba_Title
        FROM Deleted


    Declare @prba_Company nvarchar(500)
    Declare @prba_Title nvarchar(50)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prba_PersonId,prba_Company,prba_Title
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prba_Company,@prba_Title
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_PersonId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Background ' + convert(varchar,@prba_PersonBackgroundId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = convert(varchar(50), @prba_Company)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        SET @NewValueTemp = convert(varchar(50), @prba_Title)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Background', @Action, 
            'prba_Company,prba_Title', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prba_Company,@prba_Title
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRPersonEvent_ioupd
 * 
 * Table:  PRPersonEvent
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRPersonEvent_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRPersonEvent_ioupd]
GO

CREATE TRIGGER dbo.trg_PRPersonEvent_ioupd
ON PRPersonEvent
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prpe_PersonEventId int
    Declare @UserId int
    Declare @PersonId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prpe_PersonId, @UserId = i.prpe_UpdatedBy, @prpe_PersonEventId = i.prpe_PersonEventId
        FROM Inserted i
        INNER JOIN deleted d ON i.prpe_PersonEventId = d.prpe_PersonEventId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_PersonId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prpe_PersonEventTypeId) OR
        Update (prpe_Date) OR
        Update (prpe_Description) OR
        Update (prpe_EducationalInstitution) OR
        Update (prpe_EducationalDegree) OR
        Update (prpe_BankruptcyType) OR
        Update (prpe_USBankruptcyVoluntary) OR
        Update (prpe_USBankruptcyCourt) OR
        Update (prpe_CaseNumber) OR
        Update (prpe_DischargeType) OR
        Update (prpe_PublishedAnalysis) OR
        Update (prpe_InternalAnalysis) OR
        Update (prpe_PublishUntilDate) OR
        Update (prpe_PublishCreditSheet) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Person Event ' + convert(varchar,@prpe_PersonEventId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prpe_PersonEventTypeId int, @del_prpe_PersonEventTypeId int
        Declare @ins_prpe_Date datetime, @del_prpe_Date datetime
        Declare @ins_prpe_Description nvarchar(75), @del_prpe_Description nvarchar(75)
        Declare @ins_prpe_EducationalInstitution nvarchar(75), @del_prpe_EducationalInstitution nvarchar(75)
        Declare @ins_prpe_EducationalDegree nvarchar(75), @del_prpe_EducationalDegree nvarchar(75)
        Declare @ins_prpe_BankruptcyType nvarchar(40), @del_prpe_BankruptcyType nvarchar(40)
        Declare @ins_prpe_USBankruptcyVoluntary nchar(1), @del_prpe_USBankruptcyVoluntary nchar(1)
        Declare @ins_prpe_USBankruptcyCourt nvarchar(40), @del_prpe_USBankruptcyCourt nvarchar(40)
        Declare @ins_prpe_CaseNumber nvarchar(25), @del_prpe_CaseNumber nvarchar(25)
        Declare @ins_prpe_DischargeType nvarchar(40), @del_prpe_DischargeType nvarchar(40)
        Declare @ins_prpe_PublishedAnalysis varchar(max), @del_prpe_PublishedAnalysis varchar(max)
        Declare @ins_prpe_InternalAnalysis varchar(max), @del_prpe_InternalAnalysis varchar(max)
        Declare @ins_prpe_PublishUntilDate datetime, @del_prpe_PublishUntilDate datetime
        Declare @ins_prpe_PublishCreditSheet nchar(1), @del_prpe_PublishCreditSheet nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prpe_PersonEventTypeId = i.prpe_PersonEventTypeId, @del_prpe_PersonEventTypeId = d.prpe_PersonEventTypeId,
            @ins_prpe_Date = i.prpe_Date, @del_prpe_Date = d.prpe_Date,
            @ins_prpe_Description = i.prpe_Description, @del_prpe_Description = d.prpe_Description,
            @ins_prpe_EducationalInstitution = i.prpe_EducationalInstitution, @del_prpe_EducationalInstitution = d.prpe_EducationalInstitution,
            @ins_prpe_EducationalDegree = i.prpe_EducationalDegree, @del_prpe_EducationalDegree = d.prpe_EducationalDegree,
            @ins_prpe_BankruptcyType = i.prpe_BankruptcyType, @del_prpe_BankruptcyType = d.prpe_BankruptcyType,
            @ins_prpe_USBankruptcyVoluntary = i.prpe_USBankruptcyVoluntary, @del_prpe_USBankruptcyVoluntary = d.prpe_USBankruptcyVoluntary,
            @ins_prpe_USBankruptcyCourt = i.prpe_USBankruptcyCourt, @del_prpe_USBankruptcyCourt = d.prpe_USBankruptcyCourt,
            @ins_prpe_CaseNumber = i.prpe_CaseNumber, @del_prpe_CaseNumber = d.prpe_CaseNumber,
            @ins_prpe_DischargeType = i.prpe_DischargeType, @del_prpe_DischargeType = d.prpe_DischargeType,
            @ins_prpe_PublishedAnalysis = i.prpe_PublishedAnalysis, @del_prpe_PublishedAnalysis = d.prpe_PublishedAnalysis,
            @ins_prpe_InternalAnalysis = i.prpe_InternalAnalysis, @del_prpe_InternalAnalysis = d.prpe_InternalAnalysis,
            @ins_prpe_PublishUntilDate = i.prpe_PublishUntilDate, @del_prpe_PublishUntilDate = d.prpe_PublishUntilDate,
            @ins_prpe_PublishCreditSheet = i.prpe_PublishCreditSheet, @del_prpe_PublishCreditSheet = d.prpe_PublishCreditSheet
        FROM Inserted i
        INNER JOIN deleted d ON i.prpe_PersonEventId = d.prpe_PersonEventId

        -- prpe_PersonEventTypeId
        IF  (  Update(prpe_PersonEventTypeId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prpt_Name FROM PRPersonEventType WITH (NOLOCK) 
                WHERE prpt_PersonEventTypeId = @ins_prpe_PersonEventTypeId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_prpe_PersonEventTypeId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prpt_Name FROM PRPersonEventType WITH (NOLOCK) 
                WHERE prpt_PersonEventTypeId = @del_prpe_PersonEventTypeId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_prpe_PersonEventTypeId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_PersonEventTypeId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_Date
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prpe_Date, @ins_prpe_Date) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prpe_Date IS NOT NULL AND convert(varchar,@del_prpe_Date,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_prpe_Date)
            IF (@ins_prpe_Date IS NOT NULL AND convert(varchar,@ins_prpe_Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_prpe_Date)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_Date', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_Description
        IF  (  Update(prpe_Description))
        BEGIN
            SET @OldValue =  @del_prpe_Description
            SET @NewValue =  @ins_prpe_Description
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_Description', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_EducationalInstitution
        IF  (  Update(prpe_EducationalInstitution))
        BEGIN
            SET @OldValue =  @del_prpe_EducationalInstitution
            SET @NewValue =  @ins_prpe_EducationalInstitution
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_EducationalInstitution', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_EducationalDegree
        IF  (  Update(prpe_EducationalDegree))
        BEGIN
            SET @OldValue =  @del_prpe_EducationalDegree
            SET @NewValue =  @ins_prpe_EducationalDegree
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_EducationalDegree', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_BankruptcyType
        IF  (  Update(prpe_BankruptcyType))
        BEGIN
            SET @OldValue =  @del_prpe_BankruptcyType
            SET @NewValue =  @ins_prpe_BankruptcyType
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_BankruptcyType', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_USBankruptcyVoluntary
        IF  (  Update(prpe_USBankruptcyVoluntary))
        BEGIN
            SET @OldValue =  @del_prpe_USBankruptcyVoluntary
            SET @NewValue =  @ins_prpe_USBankruptcyVoluntary
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_USBankruptcyVoluntary', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_USBankruptcyCourt
        IF  (  Update(prpe_USBankruptcyCourt))
        BEGIN
            SET @OldValue =  @del_prpe_USBankruptcyCourt
            SET @NewValue =  @ins_prpe_USBankruptcyCourt
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_USBankruptcyCourt', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_CaseNumber
        IF  (  Update(prpe_CaseNumber))
        BEGIN
            SET @OldValue =  @del_prpe_CaseNumber
            SET @NewValue =  @ins_prpe_CaseNumber
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_CaseNumber', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_DischargeType
        IF  (  Update(prpe_DischargeType))
        BEGIN
            SET @OldValue =  @del_prpe_DischargeType
            SET @NewValue =  @ins_prpe_DischargeType
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_DischargeType', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_PublishedAnalysis
        IF  (  Update(prpe_PublishedAnalysis))
        BEGIN
            SET @OldValue =  @del_prpe_PublishedAnalysis
            SET @NewValue =  @ins_prpe_PublishedAnalysis
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_PublishedAnalysis', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_InternalAnalysis
        IF  (  Update(prpe_InternalAnalysis))
        BEGIN
            SET @OldValue =  @del_prpe_InternalAnalysis
            SET @NewValue =  @ins_prpe_InternalAnalysis
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_InternalAnalysis', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_PublishUntilDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prpe_PublishUntilDate, @ins_prpe_PublishUntilDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prpe_PublishUntilDate IS NOT NULL AND convert(varchar,@del_prpe_PublishUntilDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_prpe_PublishUntilDate)
            IF (@ins_prpe_PublishUntilDate IS NOT NULL AND convert(varchar,@ins_prpe_PublishUntilDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_prpe_PublishUntilDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_PublishUntilDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_PublishCreditSheet
        IF  (  Update(prpe_PublishCreditSheet))
        BEGIN
            SET @OldValue =  @del_prpe_PublishCreditSheet
            SET @NewValue =  @ins_prpe_PublishCreditSheet
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_PublishCreditSheet', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRPersonEvent SET 
        PRPersonEvent.prpe_PersonEventId=i.prpe_PersonEventId, 
        PRPersonEvent.prpe_Deleted=i.prpe_Deleted, 
        PRPersonEvent.prpe_WorkflowId=i.prpe_WorkflowId, 
        PRPersonEvent.prpe_Secterr=i.prpe_Secterr, 
        PRPersonEvent.prpe_CreatedBy=i.prpe_CreatedBy, 
        PRPersonEvent.prpe_CreatedDate=dbo.ufn_GetAccpacDate(i.prpe_CreatedDate), 
        PRPersonEvent.prpe_UpdatedBy=i.prpe_UpdatedBy, 
        PRPersonEvent.prpe_UpdatedDate=dbo.ufn_GetAccpacDate(i.prpe_UpdatedDate), 
        PRPersonEvent.prpe_TimeStamp=dbo.ufn_GetAccpacDate(i.prpe_TimeStamp), 
        PRPersonEvent.prpe_PersonId=i.prpe_PersonId, 
        PRPersonEvent.prpe_PersonEventTypeId=i.prpe_PersonEventTypeId, 
        PRPersonEvent.prpe_Date=dbo.ufn_GetAccpacDate(i.prpe_Date), 
        PRPersonEvent.prpe_Description=i.prpe_Description, 
        PRPersonEvent.prpe_EducationalInstitution=i.prpe_EducationalInstitution, 
        PRPersonEvent.prpe_EducationalDegree=i.prpe_EducationalDegree, 
        PRPersonEvent.prpe_BankruptcyType=i.prpe_BankruptcyType, 
        PRPersonEvent.prpe_USBankruptcyVoluntary=i.prpe_USBankruptcyVoluntary, 
        PRPersonEvent.prpe_USBankruptcyCourt=i.prpe_USBankruptcyCourt, 
        PRPersonEvent.prpe_CaseNumber=i.prpe_CaseNumber, 
        PRPersonEvent.prpe_DischargeType=i.prpe_DischargeType, 
        PRPersonEvent.prpe_PublishedAnalysis=i.prpe_PublishedAnalysis, 
        PRPersonEvent.prpe_InternalAnalysis=i.prpe_InternalAnalysis, 
        PRPersonEvent.prpe_PublishUntilDate=dbo.ufn_GetAccpacDate(i.prpe_PublishUntilDate), 
        PRPersonEvent.prpe_PublishCreditSheet=i.prpe_PublishCreditSheet, 
        PRPersonEvent.prpe_DisplayedEffectiveDate=i.prpe_DisplayedEffectiveDate, 
        PRPersonEvent.prpe_DisplayedEffectiveDateStyle=i.prpe_DisplayedEffectiveDateStyle
        FROM inserted i 
          INNER JOIN PRPersonEvent ON i.prpe_PersonEventId=PRPersonEvent.prpe_PersonEventId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRPersonRelationship_ioupd
 * 
 * Table:  PRPersonRelationship
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRPersonRelationship_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRPersonRelationship_ioupd]
GO

CREATE TRIGGER dbo.trg_PRPersonRelationship_ioupd
ON PRPersonRelationship
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prpr_PersonRelationshipId int
    Declare @UserId int
    Declare @PersonId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prpr_LeftPersonId, @UserId = i.prpr_UpdatedBy, @prpr_PersonRelationshipId = i.prpr_PersonRelationshipId
        FROM Inserted i
        INNER JOIN deleted d ON i.prpr_PersonRelationshipId = d.prpr_PersonRelationshipId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_PersonId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prpr_RightPersonId) OR
        Update (prpr_Description) OR
        Update (prpr_Source) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Person Relationship ' + convert(varchar,@prpr_PersonRelationshipId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prpr_RightPersonId int, @del_prpr_RightPersonId int
        Declare @ins_prpr_Description nvarchar(200), @del_prpr_Description nvarchar(200)
        Declare @ins_prpr_Source nvarchar(40), @del_prpr_Source nvarchar(40)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prpr_RightPersonId = i.prpr_RightPersonId, @del_prpr_RightPersonId = d.prpr_RightPersonId,
            @ins_prpr_Description = i.prpr_Description, @del_prpr_Description = d.prpr_Description,
            @ins_prpr_Source = i.prpr_Source, @del_prpr_Source = d.prpr_Source
        FROM Inserted i
        INNER JOIN deleted d ON i.prpr_PersonRelationshipId = d.prpr_PersonRelationshipId

        -- prpr_RightPersonId
        IF  (  Update(prpr_RightPersonId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_LastName FROM Person WITH (NOLOCK) 
                WHERE pers_personid = @ins_prpr_RightPersonId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_prpr_RightPersonId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_LastName FROM Person WITH (NOLOCK) 
                WHERE pers_personid = @del_prpr_RightPersonId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_prpr_RightPersonId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Relationship', @Action, 'prpr_RightPersonId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpr_Description
        IF  (  Update(prpr_Description))
        BEGIN
            SET @OldValue =  @del_prpr_Description
            SET @NewValue =  @ins_prpr_Description
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Relationship', @Action, 'prpr_Description', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpr_Source
        IF  (  Update(prpr_Source))
        BEGIN
            SET @OldValue =  @del_prpr_Source
            SET @NewValue =  @ins_prpr_Source
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Relationship', @Action, 'prpr_Source', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRPersonRelationship SET 
        PRPersonRelationship.prpr_PersonRelationshipId=i.prpr_PersonRelationshipId, 
        PRPersonRelationship.prpr_Deleted=i.prpr_Deleted, 
        PRPersonRelationship.prpr_WorkflowId=i.prpr_WorkflowId, 
        PRPersonRelationship.prpr_Secterr=i.prpr_Secterr, 
        PRPersonRelationship.prpr_CreatedBy=i.prpr_CreatedBy, 
        PRPersonRelationship.prpr_CreatedDate=dbo.ufn_GetAccpacDate(i.prpr_CreatedDate), 
        PRPersonRelationship.prpr_UpdatedBy=i.prpr_UpdatedBy, 
        PRPersonRelationship.prpr_UpdatedDate=dbo.ufn_GetAccpacDate(i.prpr_UpdatedDate), 
        PRPersonRelationship.prpr_TimeStamp=dbo.ufn_GetAccpacDate(i.prpr_TimeStamp), 
        PRPersonRelationship.prpr_LeftPersonId=i.prpr_LeftPersonId, 
        PRPersonRelationship.prpr_RightPersonId=i.prpr_RightPersonId, 
        PRPersonRelationship.prpr_Description=i.prpr_Description, 
        PRPersonRelationship.prpr_Source=i.prpr_Source
        FROM inserted i 
          INNER JOIN PRPersonRelationship ON i.prpr_PersonRelationshipId=PRPersonRelationship.prpr_PersonRelationshipId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRPersonRelationship_insdel
 * 
 * Table:  PRPersonRelationship
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRPersonRelationship_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRPersonRelationship_insdel]
GO

CREATE TRIGGER dbo.trg_PRPersonRelationship_insdel
ON PRPersonRelationship
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @prpr_PersonRelationshipId int
    Declare @UserId int
    Declare @PersonId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prpr_LeftPersonId int, prpr_RightPersonId int, prpr_Description nvarchar(200))
    INSERT INTO @ProcessTable
        SELECT 'Insert',prpr_LeftPersonId,prpr_RightPersonId,prpr_Description
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prpr_LeftPersonId,prpr_RightPersonId,prpr_Description
        FROM Deleted


    Declare @prpr_RightPersonId int
    Declare @prpr_Description nvarchar(200)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prpr_LeftPersonId,prpr_RightPersonId,prpr_Description
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prpr_RightPersonId,@prpr_Description
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE prtx_PersonId = @TrxKeyId
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Person Relationship ' + convert(varchar,@prpr_PersonRelationshipId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = pers_LastName FROM Person WITH (NOLOCK) 
                WHERE pers_personid = @prpr_RightPersonId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prpr_RightPersonId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        SET @NewValueTemp = convert(varchar(50), @prpr_Description)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Relationship', @Action, 
            'pers_LastName,prpr_Description', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prpr_RightPersonId,@prpr_Description
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
