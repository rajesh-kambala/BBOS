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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Update (Comp_PhoneCountryCode) OR
        Update (Comp_PhoneAreaCode) OR
        Update (Comp_PhoneNumber) OR
        Update (Comp_FaxCountryCode) OR
        Update (Comp_FaxAreaCode) OR
        Update (Comp_FaxNumber) OR
        Update (Comp_Deleted) OR
        Update (comp_PRHQId) OR
        Update (comp_PRCorrTradestyle) OR
        Update (comp_PRBookTradestyle) OR
        Update (comp_PRSubordinationAgrProvided) OR
        Update (comp_PRSubordinationAgrDate) OR
        Update (comp_PRRequestFinancials) OR
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
        Update (comp_PRUnloadHours) OR
        Update (comp_PRPublishUnloadHours) OR
        Update (comp_PRPublishDL) OR
        Update (comp_PRMoralResponsibility) OR
        Update (comp_PRHandlesInvoicing) OR
        Update (comp_PRReceiveLRL) OR
        Update (comp_PRTMFMAward) OR
        Update (comp_PRTMFMAwardDate) OR
        Update (comp_PRTMFMCandidate) OR
        Update (comp_PRTMFMCandidateDate) OR
        Update (comp_PRAdministrativeUsage) OR
        Update (comp_PRReceiveTES) OR
        Update (comp_PRCreditWorthCap) OR
        Update (comp_PRConfidentialFS) OR
        Update (comp_PRSpotlight) OR
        Update (comp_PRUnattributedOwnerPct) OR
        Update (comp_PRBusinessReport) OR
        Update (comp_PRWebActivated) OR
        Update (comp_PRWebActivatedDate) OR
        Update (comp_PRServicesThroughCompanyId) OR
        Update (comp_PRIndustryType) OR
        Update (comp_PRReceivesBBScoreReport) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company ' + convert(varchar,@Comp_CompanyId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

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
        Declare @ins_Comp_PhoneCountryCode nchar(5), @del_Comp_PhoneCountryCode nchar(5)
        Declare @ins_Comp_PhoneAreaCode nchar(20), @del_Comp_PhoneAreaCode nchar(20)
        Declare @ins_Comp_PhoneNumber nchar(20), @del_Comp_PhoneNumber nchar(20)
        Declare @ins_Comp_FaxCountryCode nchar(5), @del_Comp_FaxCountryCode nchar(5)
        Declare @ins_Comp_FaxAreaCode nchar(20), @del_Comp_FaxAreaCode nchar(20)
        Declare @ins_Comp_FaxNumber nchar(20), @del_Comp_FaxNumber nchar(20)
        Declare @ins_Comp_Deleted tinyint, @del_Comp_Deleted tinyint
        Declare @ins_comp_PRHQId int, @del_comp_PRHQId int
        Declare @ins_comp_PRCorrTradestyle nvarchar(104), @del_comp_PRCorrTradestyle nvarchar(104)
        Declare @ins_comp_PRBookTradestyle nvarchar(104), @del_comp_PRBookTradestyle nvarchar(104)
        Declare @ins_comp_PRSubordinationAgrProvided nchar(1), @del_comp_PRSubordinationAgrProvided nchar(1)
        Declare @ins_comp_PRSubordinationAgrDate datetime, @del_comp_PRSubordinationAgrDate datetime
        Declare @ins_comp_PRRequestFinancials nchar(1), @del_comp_PRRequestFinancials nchar(1)
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
        Declare @ins_comp_PRUnloadHours nvarchar(255), @del_comp_PRUnloadHours nvarchar(255)
        Declare @ins_comp_PRPublishUnloadHours nchar(1), @del_comp_PRPublishUnloadHours nchar(1)
        Declare @ins_comp_PRPublishDL nchar(1), @del_comp_PRPublishDL nchar(1)
        Declare @ins_comp_PRMoralResponsibility nvarchar(10), @del_comp_PRMoralResponsibility nvarchar(10)
        Declare @ins_comp_PRHandlesInvoicing nchar(1), @del_comp_PRHandlesInvoicing nchar(1)
        Declare @ins_comp_PRReceiveLRL nchar(1), @del_comp_PRReceiveLRL nchar(1)
        Declare @ins_comp_PRTMFMAward nchar(1), @del_comp_PRTMFMAward nchar(1)
        Declare @ins_comp_PRTMFMAwardDate datetime, @del_comp_PRTMFMAwardDate datetime
        Declare @ins_comp_PRTMFMCandidate nchar(1), @del_comp_PRTMFMCandidate nchar(1)
        Declare @ins_comp_PRTMFMCandidateDate datetime, @del_comp_PRTMFMCandidateDate datetime
        Declare @ins_comp_PRAdministrativeUsage nvarchar(100), @del_comp_PRAdministrativeUsage nvarchar(100)
        Declare @ins_comp_PRReceiveTES nchar(1), @del_comp_PRReceiveTES nchar(1)
        Declare @ins_comp_PRCreditWorthCap int, @del_comp_PRCreditWorthCap int
        Declare @ins_comp_PRConfidentialFS nchar(1), @del_comp_PRConfidentialFS nchar(1)
        Declare @ins_comp_PRSpotlight nvarchar(100), @del_comp_PRSpotlight nvarchar(100)
        Declare @ins_comp_PRUnattributedOwnerPct int, @del_comp_PRUnattributedOwnerPct int
        Declare @ins_comp_PRBusinessReport nchar(1), @del_comp_PRBusinessReport nchar(1)
        Declare @ins_comp_PRWebActivated nchar(1), @del_comp_PRWebActivated nchar(1)
        Declare @ins_comp_PRWebActivatedDate datetime, @del_comp_PRWebActivatedDate datetime
        Declare @ins_comp_PRServicesThroughCompanyId int, @del_comp_PRServicesThroughCompanyId int
        Declare @ins_comp_PRIndustryType nvarchar(40), @del_comp_PRIndustryType nvarchar(40)
        Declare @ins_comp_PRReceivesBBScoreReport nchar(1), @del_comp_PRReceivesBBScoreReport nchar(1)
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
            @ins_Comp_PhoneCountryCode = i.Comp_PhoneCountryCode, @del_Comp_PhoneCountryCode = d.Comp_PhoneCountryCode,
            @ins_Comp_PhoneAreaCode = i.Comp_PhoneAreaCode, @del_Comp_PhoneAreaCode = d.Comp_PhoneAreaCode,
            @ins_Comp_PhoneNumber = i.Comp_PhoneNumber, @del_Comp_PhoneNumber = d.Comp_PhoneNumber,
            @ins_Comp_FaxCountryCode = i.Comp_FaxCountryCode, @del_Comp_FaxCountryCode = d.Comp_FaxCountryCode,
            @ins_Comp_FaxAreaCode = i.Comp_FaxAreaCode, @del_Comp_FaxAreaCode = d.Comp_FaxAreaCode,
            @ins_Comp_FaxNumber = i.Comp_FaxNumber, @del_Comp_FaxNumber = d.Comp_FaxNumber,
            @ins_Comp_Deleted = i.Comp_Deleted, @del_Comp_Deleted = d.Comp_Deleted,
            @ins_comp_PRHQId = i.comp_PRHQId, @del_comp_PRHQId = d.comp_PRHQId,
            @ins_comp_PRCorrTradestyle = i.comp_PRCorrTradestyle, @del_comp_PRCorrTradestyle = d.comp_PRCorrTradestyle,
            @ins_comp_PRBookTradestyle = i.comp_PRBookTradestyle, @del_comp_PRBookTradestyle = d.comp_PRBookTradestyle,
            @ins_comp_PRSubordinationAgrProvided = i.comp_PRSubordinationAgrProvided, @del_comp_PRSubordinationAgrProvided = d.comp_PRSubordinationAgrProvided,
            @ins_comp_PRSubordinationAgrDate = i.comp_PRSubordinationAgrDate, @del_comp_PRSubordinationAgrDate = d.comp_PRSubordinationAgrDate,
            @ins_comp_PRRequestFinancials = i.comp_PRRequestFinancials, @del_comp_PRRequestFinancials = d.comp_PRRequestFinancials,
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
            @ins_comp_PRUnloadHours = i.comp_PRUnloadHours, @del_comp_PRUnloadHours = d.comp_PRUnloadHours,
            @ins_comp_PRPublishUnloadHours = i.comp_PRPublishUnloadHours, @del_comp_PRPublishUnloadHours = d.comp_PRPublishUnloadHours,
            @ins_comp_PRPublishDL = i.comp_PRPublishDL, @del_comp_PRPublishDL = d.comp_PRPublishDL,
            @ins_comp_PRMoralResponsibility = i.comp_PRMoralResponsibility, @del_comp_PRMoralResponsibility = d.comp_PRMoralResponsibility,
            @ins_comp_PRHandlesInvoicing = i.comp_PRHandlesInvoicing, @del_comp_PRHandlesInvoicing = d.comp_PRHandlesInvoicing,
            @ins_comp_PRReceiveLRL = i.comp_PRReceiveLRL, @del_comp_PRReceiveLRL = d.comp_PRReceiveLRL,
            @ins_comp_PRTMFMAward = i.comp_PRTMFMAward, @del_comp_PRTMFMAward = d.comp_PRTMFMAward,
            @ins_comp_PRTMFMAwardDate = i.comp_PRTMFMAwardDate, @del_comp_PRTMFMAwardDate = d.comp_PRTMFMAwardDate,
            @ins_comp_PRTMFMCandidate = i.comp_PRTMFMCandidate, @del_comp_PRTMFMCandidate = d.comp_PRTMFMCandidate,
            @ins_comp_PRTMFMCandidateDate = i.comp_PRTMFMCandidateDate, @del_comp_PRTMFMCandidateDate = d.comp_PRTMFMCandidateDate,
            @ins_comp_PRAdministrativeUsage = i.comp_PRAdministrativeUsage, @del_comp_PRAdministrativeUsage = d.comp_PRAdministrativeUsage,
            @ins_comp_PRReceiveTES = i.comp_PRReceiveTES, @del_comp_PRReceiveTES = d.comp_PRReceiveTES,
            @ins_comp_PRCreditWorthCap = i.comp_PRCreditWorthCap, @del_comp_PRCreditWorthCap = d.comp_PRCreditWorthCap,
            @ins_comp_PRConfidentialFS = i.comp_PRConfidentialFS, @del_comp_PRConfidentialFS = d.comp_PRConfidentialFS,
            @ins_comp_PRSpotlight = i.comp_PRSpotlight, @del_comp_PRSpotlight = d.comp_PRSpotlight,
            @ins_comp_PRUnattributedOwnerPct = i.comp_PRUnattributedOwnerPct, @del_comp_PRUnattributedOwnerPct = d.comp_PRUnattributedOwnerPct,
            @ins_comp_PRBusinessReport = i.comp_PRBusinessReport, @del_comp_PRBusinessReport = d.comp_PRBusinessReport,
            @ins_comp_PRWebActivated = i.comp_PRWebActivated, @del_comp_PRWebActivated = d.comp_PRWebActivated,
            @ins_comp_PRWebActivatedDate = i.comp_PRWebActivatedDate, @del_comp_PRWebActivatedDate = d.comp_PRWebActivatedDate,
            @ins_comp_PRServicesThroughCompanyId = i.comp_PRServicesThroughCompanyId, @del_comp_PRServicesThroughCompanyId = d.comp_PRServicesThroughCompanyId,
            @ins_comp_PRIndustryType = i.comp_PRIndustryType, @del_comp_PRIndustryType = d.comp_PRIndustryType,
            @ins_comp_PRReceivesBBScoreReport = i.comp_PRReceivesBBScoreReport, @del_comp_PRReceivesBBScoreReport = d.comp_PRReceivesBBScoreReport
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
        -- Comp_PhoneCountryCode
        IF  (  Update(Comp_PhoneCountryCode))
        BEGIN
            SET @OldValue =  @del_Comp_PhoneCountryCode
            SET @NewValue =  @ins_Comp_PhoneCountryCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_PhoneCountryCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_PhoneAreaCode
        IF  (  Update(Comp_PhoneAreaCode))
        BEGIN
            SET @OldValue =  @del_Comp_PhoneAreaCode
            SET @NewValue =  @ins_Comp_PhoneAreaCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_PhoneAreaCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_PhoneNumber
        IF  (  Update(Comp_PhoneNumber))
        BEGIN
            SET @OldValue =  @del_Comp_PhoneNumber
            SET @NewValue =  @ins_Comp_PhoneNumber
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_PhoneNumber', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_FaxCountryCode
        IF  (  Update(Comp_FaxCountryCode))
        BEGIN
            SET @OldValue =  @del_Comp_FaxCountryCode
            SET @NewValue =  @ins_Comp_FaxCountryCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_FaxCountryCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_FaxAreaCode
        IF  (  Update(Comp_FaxAreaCode))
        BEGIN
            SET @OldValue =  @del_Comp_FaxAreaCode
            SET @NewValue =  @ins_Comp_FaxAreaCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_FaxAreaCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_FaxNumber
        IF  (  Update(Comp_FaxNumber))
        BEGIN
            SET @OldValue =  @del_Comp_FaxNumber
            SET @NewValue =  @ins_Comp_FaxNumber
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_FaxNumber', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Comp_Deleted
        IF  (  Update(Comp_Deleted))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_Comp_Deleted)
            SET @NewValue =  convert(varchar(3000), @ins_Comp_Deleted)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'Comp_Deleted', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRHQId
        IF  (  Update(comp_PRHQId))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_comp_PRHQId)
            SET @NewValue =  convert(varchar(3000), @ins_comp_PRHQId)
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
                SET @OldValue =  convert(varchar(3000), @del_comp_PRSubordinationAgrDate)
            IF (@ins_comp_PRSubordinationAgrDate IS NOT NULL AND convert(varchar,@ins_comp_PRSubordinationAgrDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_comp_PRSubordinationAgrDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRSubordinationAgrDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRRequestFinancials
        IF  (  Update(comp_PRRequestFinancials))
        BEGIN
            SET @OldValue =  @del_comp_PRRequestFinancials
            SET @NewValue =  @ins_comp_PRRequestFinancials
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRRequestFinancials', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
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
            SELECT @NewValueTemp = CityStateCountryShort FROM vPRLocation
                WHERE prci_CityID = @ins_comp_PRListingCityId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_comp_PRListingCityId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = CityStateCountryShort FROM vPRLocation
                WHERE prci_CityID = @del_comp_PRListingCityId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_comp_PRListingCityId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRListingCityId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRListingStatus
        IF  (  Update(comp_PRListingStatus))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='comp_PRListingStatus' AND capt_code = @ins_comp_PRListingStatus
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_comp_PRListingStatus)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
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
                SET @OldValue =  convert(varchar(3000), @del_comp_PROldName1Date)
            IF (@ins_comp_PROldName1Date IS NOT NULL AND convert(varchar,@ins_comp_PROldName1Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_comp_PROldName1Date)
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
                SET @OldValue =  convert(varchar(3000), @del_comp_PROldName2Date)
            IF (@ins_comp_PROldName2Date IS NOT NULL AND convert(varchar,@ins_comp_PROldName2Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_comp_PROldName2Date)
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
                SET @OldValue =  convert(varchar(3000), @del_comp_PROldName3Date)
            IF (@ins_comp_PROldName3Date IS NOT NULL AND convert(varchar,@ins_comp_PROldName3Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_comp_PROldName3Date)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PROldName3Date', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRType
        IF  (  Update(comp_PRType))
        BEGIN
            SET @OldValue =  @del_comp_PRType
            SET @NewValue =  @ins_comp_PRType
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRType', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRUnloadHours
        IF  (  Update(comp_PRUnloadHours))
        BEGIN
            SET @OldValue =  @del_comp_PRUnloadHours
            SET @NewValue =  @ins_comp_PRUnloadHours
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRUnloadHours', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
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
                SET @OldValue =  convert(varchar(3000), @del_comp_PRTMFMAwardDate)
            IF (@ins_comp_PRTMFMAwardDate IS NOT NULL AND convert(varchar,@ins_comp_PRTMFMAwardDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_comp_PRTMFMAwardDate)
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
                SET @OldValue =  convert(varchar(3000), @del_comp_PRTMFMCandidateDate)
            IF (@ins_comp_PRTMFMCandidateDate IS NOT NULL AND convert(varchar,@ins_comp_PRTMFMCandidateDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_comp_PRTMFMCandidateDate)
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
            SELECT @NewValueTemp = prcw_Name FROM PRCreditWorthRating
                WHERE prcw_CreditWorthRatingId = @ins_comp_PRCreditWorthCap
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_comp_PRCreditWorthCap))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prcw_Name FROM PRCreditWorthRating
                WHERE prcw_CreditWorthRatingId = @del_comp_PRCreditWorthCap
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_comp_PRCreditWorthCap))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRCreditWorthCap', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRConfidentialFS
        IF  (  Update(comp_PRConfidentialFS))
        BEGIN
            SET @OldValue =  @del_comp_PRConfidentialFS
            SET @NewValue =  @ins_comp_PRConfidentialFS
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRConfidentialFS', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRSpotlight
        IF  (  Update(comp_PRSpotlight))
        BEGIN
            SET @OldValue =  @del_comp_PRSpotlight
            SET @NewValue =  @ins_comp_PRSpotlight
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRSpotlight', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRUnattributedOwnerPct
        IF  (  Update(comp_PRUnattributedOwnerPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_comp_PRUnattributedOwnerPct)
            SET @NewValue =  convert(varchar(3000), @ins_comp_PRUnattributedOwnerPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRUnattributedOwnerPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRBusinessReport
        IF  (  Update(comp_PRBusinessReport))
        BEGIN
            SET @OldValue =  @del_comp_PRBusinessReport
            SET @NewValue =  @ins_comp_PRBusinessReport
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRBusinessReport', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
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
                SET @OldValue =  convert(varchar(3000), @del_comp_PRWebActivatedDate)
            IF (@ins_comp_PRWebActivatedDate IS NOT NULL AND convert(varchar,@ins_comp_PRWebActivatedDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_comp_PRWebActivatedDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRWebActivatedDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRServicesThroughCompanyId
        IF  (  Update(comp_PRServicesThroughCompanyId))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_comp_PRServicesThroughCompanyId)
            SET @NewValue =  convert(varchar(3000), @ins_comp_PRServicesThroughCompanyId)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRServicesThroughCompanyId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- comp_PRIndustryType
        IF  (  Update(comp_PRIndustryType))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='comp_PRIndustryType' AND capt_code = @ins_comp_PRIndustryType
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_comp_PRIndustryType)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
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


        -- comp_PRSpecialInstruction
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.comp_PRSpecialInstruction, d.comp_PRSpecialInstruction
            FROM Inserted i
            INNER JOIN deleted d ON i.Comp_CompanyId = d.Comp_CompanyId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRSpecialInstruction', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- comp_PRSpecialHandlingInstruction
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.comp_PRSpecialHandlingInstruction, d.comp_PRSpecialHandlingInstruction
            FROM Inserted i
            INNER JOIN deleted d ON i.Comp_CompanyId = d.Comp_CompanyId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRSpecialHandlingInstruction', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- comp_PRTMFMComments
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.comp_PRTMFMComments, d.comp_PRTMFMComments
            FROM Inserted i
            INNER JOIN deleted d ON i.Comp_CompanyId = d.Comp_CompanyId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRTMFMComments', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- comp_PRCreditWorthCapReason
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.comp_PRCreditWorthCapReason, d.comp_PRCreditWorthCapReason
            FROM Inserted i
            INNER JOIN deleted d ON i.Comp_CompanyId = d.Comp_CompanyId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRCreditWorthCapReason', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- comp_PRUnattributedOwnerDesc
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.comp_PRUnattributedOwnerDesc, d.comp_PRUnattributedOwnerDesc
            FROM Inserted i
            INNER JOIN deleted d ON i.Comp_CompanyId = d.Comp_CompanyId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRUnattributedOwnerDesc', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- comp_PRPrincipalsBackgroundText
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.comp_PRPrincipalsBackgroundText, d.comp_PRPrincipalsBackgroundText
            FROM Inserted i
            INNER JOIN deleted d ON i.Comp_CompanyId = d.Comp_CompanyId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company', @Action, 'comp_PRPrincipalsBackgroundText', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable
        DROP TABLE #TextTable
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
        Company.Comp_PhoneCountryCode=i.Comp_PhoneCountryCode, 
        Company.Comp_PhoneAreaCode=i.Comp_PhoneAreaCode, 
        Company.Comp_PhoneNumber=i.Comp_PhoneNumber, 
        Company.Comp_FaxCountryCode=i.Comp_FaxCountryCode, 
        Company.Comp_FaxAreaCode=i.Comp_FaxAreaCode, 
        Company.Comp_FaxNumber=i.Comp_FaxNumber, 
        Company.Comp_EmailAddress=i.Comp_EmailAddress, 
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
        Company.comp_PRRequestFinancials=i.comp_PRRequestFinancials, 
        Company.comp_PRSpecialInstruction=i.comp_PRSpecialInstruction, 
        Company.comp_PRDataQualityTier=i.comp_PRDataQualityTier, 
        Company.comp_PRListingCityId=i.comp_PRListingCityId, 
        Company.comp_PRListingStatus=i.comp_PRListingStatus, 
        Company.comp_PRAccountTier=i.comp_PRAccountTier, 
        Company.comp_PRBusinessStatus=i.comp_PRBusinessStatus, 
        Company.comp_PRDaysPastDue=i.comp_PRDaysPastDue, 
        Company.comp_PRSuspendedService=i.comp_PRSuspendedService, 
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
        Company.comp_PRUnloadHours=i.comp_PRUnloadHours, 
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
        Company.comp_PRSpotlight=i.comp_PRSpotlight, 
        Company.comp_PRLogo=i.comp_PRLogo, 
        Company.comp_PRUnattributedOwnerPct=i.comp_PRUnattributedOwnerPct, 
        Company.comp_PRUnattributedOwnerDesc=i.comp_PRUnattributedOwnerDesc, 
        Company.comp_PRConnectionListDate=dbo.ufn_GetAccpacDate(i.comp_PRConnectionListDate), 
        Company.comp_PRBusinessReport=i.comp_PRBusinessReport, 
        Company.comp_PRPrincipalsBackgroundText=i.comp_PRPrincipalsBackgroundText, 
        Company.comp_PRDLDaysPastDue=i.comp_PRDLDaysPastDue, 
        Company.comp_PRWebActivated=i.comp_PRWebActivated, 
        Company.comp_PRWebActivatedDate=dbo.ufn_GetAccpacDate(i.comp_PRWebActivatedDate), 
        Company.comp_PRServicesThroughCompanyId=i.comp_PRServicesThroughCompanyId, 
        Company.comp_PRIndustryType=i.comp_PRIndustryType, 
        Company.comp_PRReceivesBBScoreReport=i.comp_PRReceivesBBScoreReport
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Update (prcb_Telephone) OR
        Update (prcb_Fax) OR
        Update (prcb_Website) OR
        Update (prcb_Publish) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Bank ' + convert(varchar,@prcb_CompanyBankId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

        Declare @ins_prcb_Name nvarchar(100), @del_prcb_Name nvarchar(100)
        Declare @ins_prcb_Address1 nvarchar(50), @del_prcb_Address1 nvarchar(50)
        Declare @ins_prcb_Address2 nvarchar(50), @del_prcb_Address2 nvarchar(50)
        Declare @ins_prcb_City nvarchar(20), @del_prcb_City nvarchar(20)
        Declare @ins_prcb_State nvarchar(10), @del_prcb_State nvarchar(10)
        Declare @ins_prcb_PostalCode nvarchar(10), @del_prcb_PostalCode nvarchar(10)
        Declare @ins_prcb_Telephone nvarchar(20), @del_prcb_Telephone nvarchar(20)
        Declare @ins_prcb_Fax nvarchar(20), @del_prcb_Fax nvarchar(20)
        Declare @ins_prcb_Website nvarchar(100), @del_prcb_Website nvarchar(100)
        Declare @ins_prcb_Publish nchar(1), @del_prcb_Publish nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prcb_Name = i.prcb_Name, @del_prcb_Name = d.prcb_Name,
            @ins_prcb_Address1 = i.prcb_Address1, @del_prcb_Address1 = d.prcb_Address1,
            @ins_prcb_Address2 = i.prcb_Address2, @del_prcb_Address2 = d.prcb_Address2,
            @ins_prcb_City = i.prcb_City, @del_prcb_City = d.prcb_City,
            @ins_prcb_State = i.prcb_State, @del_prcb_State = d.prcb_State,
            @ins_prcb_PostalCode = i.prcb_PostalCode, @del_prcb_PostalCode = d.prcb_PostalCode,
            @ins_prcb_Telephone = i.prcb_Telephone, @del_prcb_Telephone = d.prcb_Telephone,
            @ins_prcb_Fax = i.prcb_Fax, @del_prcb_Fax = d.prcb_Fax,
            @ins_prcb_Website = i.prcb_Website, @del_prcb_Website = d.prcb_Website,
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
        -- prcb_Publish
        IF  (  Update(prcb_Publish))
        BEGIN
            SET @OldValue =  @del_prcb_Publish
            SET @NewValue =  @ins_prcb_Publish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_Publish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END


        -- prcb_AdditionalInfo
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prcb_AdditionalInfo, d.prcb_AdditionalInfo
            FROM Inserted i
            INNER JOIN deleted d ON i.prcb_CompanyBankId = d.prcb_CompanyBankId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Bank', @Action, 'prcb_AdditionalInfo', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable
        DROP TABLE #TextTable
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

        Declare @ins_prc3_Brand nvarchar(100), @del_prc3_Brand nvarchar(100)
        Declare @ins_prc3_ViewableImageLocation nvarchar(100), @del_prc3_ViewableImageLocation nvarchar(100)
        Declare @ins_prc3_PrintableImageLocation nvarchar(100), @del_prc3_PrintableImageLocation nvarchar(100)
        Declare @ins_prc3_OwningCompany nvarchar(100), @del_prc3_OwningCompany nvarchar(100)
        Declare @ins_prc3_Publish nchar(1), @del_prc3_Publish nchar(1)
        Declare @ins_prc3_Sequence int, @del_prc3_Sequence int
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prc3_Brand = i.prc3_Brand, @del_prc3_Brand = d.prc3_Brand,
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
            SET @OldValue =  convert(varchar(3000), @del_prc3_Sequence)
            SET @NewValue =  convert(varchar(3000), @ins_prc3_Sequence)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 'prc3_Sequence', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END


        -- prc3_Description
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prc3_Description, d.prc3_Description
            FROM Inserted i
            INNER JOIN deleted d ON i.prc3_CompanyBrandId = d.prc3_CompanyBrandId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Brand', @Action, 'prc3_Description', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable
        DROP TABLE #TextTable
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Update (prc2_NumberOfWarehouseStores) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Classification ' + convert(varchar,@prc2_CompanyClassificationId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

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
            @ins_prc2_NumberOfWarehouseStores = i.prc2_NumberOfWarehouseStores, @del_prc2_NumberOfWarehouseStores = d.prc2_NumberOfWarehouseStores
        FROM Inserted i
        INNER JOIN deleted d ON i.prc2_CompanyClassificationId = d.prc2_CompanyClassificationId

        -- prc2_Percentage
        IF  (  Update(prc2_Percentage))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prc2_Percentage)
            SET @NewValue =  convert(varchar(3000), @ins_prc2_Percentage)
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

        DROP TABLE #TextTable
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
        PRCompanyClassification.prc2_NumberOfWarehouseStores=i.prc2_NumberOfWarehouseStores
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        SELECT @NewValueTemp = prcl_Name FROM PRClassification
                WHERE prcl_ClassificationId = @prc2_ClassificationId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prc2_ClassificationId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
 * Name:   dbo.trg_PRCompanyCommodity_ioupd
 * 
 * Table:  PRCompanyCommodity
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyCommodity_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyCommodity_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyCommodity_ioupd
ON PRCompanyCommodity
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
    Declare @prcc_CompanyCommodityId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prcc_CompanyID, @UserId = i.prcc_UpdatedBy, @prcc_CompanyCommodityId = i.prcc_CompanyCommodityId
        FROM Inserted i
        INNER JOIN deleted d ON i.prcc_CompanyCommodityId = d.prcc_CompanyCommodityId
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
        Update (prcc_Sequence) OR
        Update (prcc_Publish) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Commodity ' + convert(varchar,@prcc_CompanyCommodityId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

        Declare @ins_prcc_Sequence int, @del_prcc_Sequence int
        Declare @ins_prcc_Publish nchar(1), @del_prcc_Publish nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prcc_Sequence = i.prcc_Sequence, @del_prcc_Sequence = d.prcc_Sequence,
            @ins_prcc_Publish = i.prcc_Publish, @del_prcc_Publish = d.prcc_Publish
        FROM Inserted i
        INNER JOIN deleted d ON i.prcc_CompanyCommodityId = d.prcc_CompanyCommodityId

        -- prcc_Sequence
        IF  (  Update(prcc_Sequence))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcc_Sequence)
            SET @NewValue =  convert(varchar(3000), @ins_prcc_Sequence)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Commodity', @Action, 'prcc_Sequence', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcc_Publish
        IF  (  Update(prcc_Publish))
        BEGIN
            SET @OldValue =  @del_prcc_Publish
            SET @NewValue =  @ins_prcc_Publish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Commodity', @Action, 'prcc_Publish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        DROP TABLE #TextTable
    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyCommodity SET 
        PRCompanyCommodity.prcc_CompanyCommodityId=i.prcc_CompanyCommodityId, 
        PRCompanyCommodity.prcc_Deleted=i.prcc_Deleted, 
        PRCompanyCommodity.prcc_WorkflowId=i.prcc_WorkflowId, 
        PRCompanyCommodity.prcc_Secterr=i.prcc_Secterr, 
        PRCompanyCommodity.prcc_CreatedBy=i.prcc_CreatedBy, 
        PRCompanyCommodity.prcc_CreatedDate=dbo.ufn_GetAccpacDate(i.prcc_CreatedDate), 
        PRCompanyCommodity.prcc_UpdatedBy=i.prcc_UpdatedBy, 
        PRCompanyCommodity.prcc_UpdatedDate=dbo.ufn_GetAccpacDate(i.prcc_UpdatedDate), 
        PRCompanyCommodity.prcc_TimeStamp=dbo.ufn_GetAccpacDate(i.prcc_TimeStamp), 
        PRCompanyCommodity.prcc_CompanyId=i.prcc_CompanyId, 
        PRCompanyCommodity.prcc_CommodityId=i.prcc_CommodityId, 
        PRCompanyCommodity.prcc_Sequence=i.prcc_Sequence, 
        PRCompanyCommodity.prcc_Publish=i.prcc_Publish
        FROM inserted i 
          INNER JOIN PRCompanyCommodity ON i.prcc_CompanyCommodityId=PRCompanyCommodity.prcc_CompanyCommodityId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRCompanyCommodity_insdel
 * 
 * Table:  PRCompanyCommodity
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyCommodity_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyCommodity_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyCommodity_insdel
ON PRCompanyCommodity
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
    Declare @prcc_CompanyCommodityId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prcc_CompanyID int, prcc_CommodityId int)
    INSERT INTO @ProcessTable
        SELECT 'Insert',prcc_CompanyID,prcc_CommodityId
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prcc_CompanyID,prcc_CommodityId
        FROM Deleted


    Declare @prcc_CommodityId int

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prcc_CompanyID,prcc_CommodityId
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prcc_CommodityId
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
            SET @Msg = 'Changes Failed.  Company Commodity ' + convert(varchar,@prcc_CompanyCommodityId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prcm_Name FROM PRCommodity
                WHERE prcm_CommodityId = @prcc_CommodityId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcc_CommodityId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Commodity', @Action, 
            'prcm_Name', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prcc_CommodityId
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

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
            SET @OldValue =  convert(varchar(3000), @del_prcca_Sequence)
            SET @NewValue =  convert(varchar(3000), @ins_prcca_Sequence)
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

        DROP TABLE #TextTable
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        SELECT @NewValueTemp = prcm_Name FROM PRCommodity
                WHERE prcm_CommodityId = @prcca_CommodityId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcca_CommodityId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prat_Name FROM PRAttribute
                WHERE prat_AttributeId = @prcca_AttributeId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcca_AttributeId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prat_Name FROM PRAttribute
                WHERE prat_AttributeId = @prcca_GrowingMethodId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcca_GrowingMethodId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

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

        DROP TABLE #TextTable
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

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

        DROP TABLE #TextTable
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        SELECT @NewValueTemp = prex_Name FROM PRStockExchange
                WHERE prex_StockExchangeId = @prc4_StockExchangeId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prc4_StockExchangeId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = convert(varchar(50), @prc4_Symbol1)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
 * Name:   dbo.trg_PRCompanyProfile_ioupd
 * 
 * Table:  PRCompanyProfile
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyProfile_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyProfile_ioupd]
GO

CREATE TRIGGER dbo.trg_PRCompanyProfile_ioupd
ON PRCompanyProfile
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
    Declare @prcp_CompanyProfileId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prcp_CompanyID, @UserId = i.prcp_UpdatedBy, @prcp_CompanyProfileId = i.prcp_CompanyProfileId
        FROM Inserted i
        INNER JOIN deleted d ON i.prcp_CompanyProfileId = d.prcp_CompanyProfileId
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
        Update (prcp_CorporateStructure) OR
        Update (prcp_Volume) OR
        Update (prcp_FTEmployees) OR
        Update (prcp_PTEmployees) OR
        Update (prcp_SrcBuyBrokersPct) OR
        Update (prcp_SrcBuyWholesalePct) OR
        Update (prcp_SrcBuyShippersPct) OR
        Update (prcp_SrcBuyExportersPct) OR
        Update (prcp_SellBrokersPct) OR
        Update (prcp_SellWholesalePct) OR
        Update (prcp_SellDomesticBuyersPct) OR
        Update (prcp_SellExportersPct) OR
        Update (prcp_SellBuyOthers) OR
        Update (prcp_SellDomesticAccountTypes) OR
        Update (prcp_BkrTakeTitlePct) OR
        Update (prcp_BkrTakePossessionPct) OR
        Update (prcp_BkrCollectPct) OR
        Update (prcp_BkrTakeFrieght) OR
        Update (prcp_BkrConfirmation) OR
        Update (prcp_BkrReceive) OR
        Update (prcp_BkrGroundInspections) OR
        Update (prcp_TrkrDirectHaulsPct) OR
        Update (prcp_TrkrTPHaulsPct) OR
        Update (prcp_TrkrProducePct) OR
        Update (prcp_TrkrOtherColdPct) OR
        Update (prcp_TrkrOtherWarmPct) OR
        Update (prcp_TrkrTeams) OR
        Update (prcp_TrkrTrucksOwned) OR
        Update (prcp_TrkrTrucksLeased) OR
        Update (prcp_TrkrTrailersOwned) OR
        Update (prcp_TrkrTrailersLeased) OR
        Update (prcp_TrkrPowerUnits) OR
        Update (prcp_TrkrReefer) OR
        Update (prcp_TrkrDryVan) OR
        Update (prcp_TrkrFlatbed) OR
        Update (prcp_TrkrPiggyback) OR
        Update (prcp_TrkrTanker) OR
        Update (prcp_TrkrContainer) OR
        Update (prcp_TrkrOther) OR
        Update (prcp_TrkrLiabilityAmount) OR
        Update (prcp_TrkrCargoAmount) OR
        Update (prcp_StorageWarehouses) OR
        Update (prcp_StorageSF) OR
        Update (prcp_StorageCF) OR
        Update (prcp_StorageBushel) OR
        Update (prcp_StorageCarlots) OR
        Update (prcp_ColdStorage) OR
        Update (prcp_RipeningStorage) OR
        Update (prcp_HumidityStorage) OR
        Update (prcp_AtmosphereStorage) OR
        Update (prcp_HAACP) OR
        Update (prcp_HAACPCertifiedBy) OR
        Update (prcp_QTV) OR
        Update (prcp_QTVCertifiedBy) OR
        Update (prcp_Organic) OR
        Update (prcp_OrganicCertifiedBy) OR
        Update (prcp_OtherCertification) OR
        Update (prcp_SellFoodWholesaler) OR
        Update (prcp_SellRetailGrocery) OR
        Update (prcp_SellInstitutions) OR
        Update (prcp_SellRestaurants) OR
        Update (prcp_SellMilitary) OR
        Update (prcp_SellDistributors) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Profile ' + convert(varchar,@prcp_CompanyProfileId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

        Declare @ins_prcp_CorporateStructure nvarchar(40), @del_prcp_CorporateStructure nvarchar(40)
        Declare @ins_prcp_Volume nvarchar(40), @del_prcp_Volume nvarchar(40)
        Declare @ins_prcp_FTEmployees nvarchar(40), @del_prcp_FTEmployees nvarchar(40)
        Declare @ins_prcp_PTEmployees nvarchar(40), @del_prcp_PTEmployees nvarchar(40)
        Declare @ins_prcp_SrcBuyBrokersPct int, @del_prcp_SrcBuyBrokersPct int
        Declare @ins_prcp_SrcBuyWholesalePct int, @del_prcp_SrcBuyWholesalePct int
        Declare @ins_prcp_SrcBuyShippersPct int, @del_prcp_SrcBuyShippersPct int
        Declare @ins_prcp_SrcBuyExportersPct int, @del_prcp_SrcBuyExportersPct int
        Declare @ins_prcp_SellBrokersPct int, @del_prcp_SellBrokersPct int
        Declare @ins_prcp_SellWholesalePct int, @del_prcp_SellWholesalePct int
        Declare @ins_prcp_SellDomesticBuyersPct int, @del_prcp_SellDomesticBuyersPct int
        Declare @ins_prcp_SellExportersPct int, @del_prcp_SellExportersPct int
        Declare @ins_prcp_SellBuyOthers nchar(1), @del_prcp_SellBuyOthers nchar(1)
        Declare @ins_prcp_SellDomesticAccountTypes nvarchar(255), @del_prcp_SellDomesticAccountTypes nvarchar(255)
        Declare @ins_prcp_BkrTakeTitlePct int, @del_prcp_BkrTakeTitlePct int
        Declare @ins_prcp_BkrTakePossessionPct int, @del_prcp_BkrTakePossessionPct int
        Declare @ins_prcp_BkrCollectPct int, @del_prcp_BkrCollectPct int
        Declare @ins_prcp_BkrTakeFrieght nchar(1), @del_prcp_BkrTakeFrieght nchar(1)
        Declare @ins_prcp_BkrConfirmation nchar(1), @del_prcp_BkrConfirmation nchar(1)
        Declare @ins_prcp_BkrReceive nvarchar(40), @del_prcp_BkrReceive nvarchar(40)
        Declare @ins_prcp_BkrGroundInspections nchar(1), @del_prcp_BkrGroundInspections nchar(1)
        Declare @ins_prcp_TrkrDirectHaulsPct int, @del_prcp_TrkrDirectHaulsPct int
        Declare @ins_prcp_TrkrTPHaulsPct int, @del_prcp_TrkrTPHaulsPct int
        Declare @ins_prcp_TrkrProducePct int, @del_prcp_TrkrProducePct int
        Declare @ins_prcp_TrkrOtherColdPct int, @del_prcp_TrkrOtherColdPct int
        Declare @ins_prcp_TrkrOtherWarmPct int, @del_prcp_TrkrOtherWarmPct int
        Declare @ins_prcp_TrkrTeams nchar(1), @del_prcp_TrkrTeams nchar(1)
        Declare @ins_prcp_TrkrTrucksOwned nvarchar(40), @del_prcp_TrkrTrucksOwned nvarchar(40)
        Declare @ins_prcp_TrkrTrucksLeased nvarchar(40), @del_prcp_TrkrTrucksLeased nvarchar(40)
        Declare @ins_prcp_TrkrTrailersOwned nvarchar(40), @del_prcp_TrkrTrailersOwned nvarchar(40)
        Declare @ins_prcp_TrkrTrailersLeased nvarchar(40), @del_prcp_TrkrTrailersLeased nvarchar(40)
        Declare @ins_prcp_TrkrPowerUnits nvarchar(40), @del_prcp_TrkrPowerUnits nvarchar(40)
        Declare @ins_prcp_TrkrReefer nvarchar(40), @del_prcp_TrkrReefer nvarchar(40)
        Declare @ins_prcp_TrkrDryVan nvarchar(40), @del_prcp_TrkrDryVan nvarchar(40)
        Declare @ins_prcp_TrkrFlatbed nvarchar(40), @del_prcp_TrkrFlatbed nvarchar(40)
        Declare @ins_prcp_TrkrPiggyback nvarchar(40), @del_prcp_TrkrPiggyback nvarchar(40)
        Declare @ins_prcp_TrkrTanker nvarchar(40), @del_prcp_TrkrTanker nvarchar(40)
        Declare @ins_prcp_TrkrContainer nvarchar(40), @del_prcp_TrkrContainer nvarchar(40)
        Declare @ins_prcp_TrkrOther nvarchar(40), @del_prcp_TrkrOther nvarchar(40)
        Declare @ins_prcp_TrkrLiabilityAmount numeric, @del_prcp_TrkrLiabilityAmount numeric
        Declare @ins_prcp_TrkrCargoAmount numeric, @del_prcp_TrkrCargoAmount numeric
        Declare @ins_prcp_StorageWarehouses int, @del_prcp_StorageWarehouses int
        Declare @ins_prcp_StorageSF nvarchar(40), @del_prcp_StorageSF nvarchar(40)
        Declare @ins_prcp_StorageCF nvarchar(40), @del_prcp_StorageCF nvarchar(40)
        Declare @ins_prcp_StorageBushel nvarchar(40), @del_prcp_StorageBushel nvarchar(40)
        Declare @ins_prcp_StorageCarlots nvarchar(40), @del_prcp_StorageCarlots nvarchar(40)
        Declare @ins_prcp_ColdStorage nchar(1), @del_prcp_ColdStorage nchar(1)
        Declare @ins_prcp_RipeningStorage nchar(1), @del_prcp_RipeningStorage nchar(1)
        Declare @ins_prcp_HumidityStorage nchar(1), @del_prcp_HumidityStorage nchar(1)
        Declare @ins_prcp_AtmosphereStorage nchar(1), @del_prcp_AtmosphereStorage nchar(1)
        Declare @ins_prcp_HAACP nchar(1), @del_prcp_HAACP nchar(1)
        Declare @ins_prcp_HAACPCertifiedBy nvarchar(30), @del_prcp_HAACPCertifiedBy nvarchar(30)
        Declare @ins_prcp_QTV nchar(1), @del_prcp_QTV nchar(1)
        Declare @ins_prcp_QTVCertifiedBy nvarchar(30), @del_prcp_QTVCertifiedBy nvarchar(30)
        Declare @ins_prcp_Organic nchar(1), @del_prcp_Organic nchar(1)
        Declare @ins_prcp_OrganicCertifiedBy nvarchar(30), @del_prcp_OrganicCertifiedBy nvarchar(30)
        Declare @ins_prcp_OtherCertification nvarchar(30), @del_prcp_OtherCertification nvarchar(30)
        Declare @ins_prcp_SellFoodWholesaler nchar(1), @del_prcp_SellFoodWholesaler nchar(1)
        Declare @ins_prcp_SellRetailGrocery nchar(1), @del_prcp_SellRetailGrocery nchar(1)
        Declare @ins_prcp_SellInstitutions nchar(1), @del_prcp_SellInstitutions nchar(1)
        Declare @ins_prcp_SellRestaurants nchar(1), @del_prcp_SellRestaurants nchar(1)
        Declare @ins_prcp_SellMilitary nchar(1), @del_prcp_SellMilitary nchar(1)
        Declare @ins_prcp_SellDistributors nchar(1), @del_prcp_SellDistributors nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prcp_CorporateStructure = i.prcp_CorporateStructure, @del_prcp_CorporateStructure = d.prcp_CorporateStructure,
            @ins_prcp_Volume = i.prcp_Volume, @del_prcp_Volume = d.prcp_Volume,
            @ins_prcp_FTEmployees = i.prcp_FTEmployees, @del_prcp_FTEmployees = d.prcp_FTEmployees,
            @ins_prcp_PTEmployees = i.prcp_PTEmployees, @del_prcp_PTEmployees = d.prcp_PTEmployees,
            @ins_prcp_SrcBuyBrokersPct = i.prcp_SrcBuyBrokersPct, @del_prcp_SrcBuyBrokersPct = d.prcp_SrcBuyBrokersPct,
            @ins_prcp_SrcBuyWholesalePct = i.prcp_SrcBuyWholesalePct, @del_prcp_SrcBuyWholesalePct = d.prcp_SrcBuyWholesalePct,
            @ins_prcp_SrcBuyShippersPct = i.prcp_SrcBuyShippersPct, @del_prcp_SrcBuyShippersPct = d.prcp_SrcBuyShippersPct,
            @ins_prcp_SrcBuyExportersPct = i.prcp_SrcBuyExportersPct, @del_prcp_SrcBuyExportersPct = d.prcp_SrcBuyExportersPct,
            @ins_prcp_SellBrokersPct = i.prcp_SellBrokersPct, @del_prcp_SellBrokersPct = d.prcp_SellBrokersPct,
            @ins_prcp_SellWholesalePct = i.prcp_SellWholesalePct, @del_prcp_SellWholesalePct = d.prcp_SellWholesalePct,
            @ins_prcp_SellDomesticBuyersPct = i.prcp_SellDomesticBuyersPct, @del_prcp_SellDomesticBuyersPct = d.prcp_SellDomesticBuyersPct,
            @ins_prcp_SellExportersPct = i.prcp_SellExportersPct, @del_prcp_SellExportersPct = d.prcp_SellExportersPct,
            @ins_prcp_SellBuyOthers = i.prcp_SellBuyOthers, @del_prcp_SellBuyOthers = d.prcp_SellBuyOthers,
            @ins_prcp_SellDomesticAccountTypes = i.prcp_SellDomesticAccountTypes, @del_prcp_SellDomesticAccountTypes = d.prcp_SellDomesticAccountTypes,
            @ins_prcp_BkrTakeTitlePct = i.prcp_BkrTakeTitlePct, @del_prcp_BkrTakeTitlePct = d.prcp_BkrTakeTitlePct,
            @ins_prcp_BkrTakePossessionPct = i.prcp_BkrTakePossessionPct, @del_prcp_BkrTakePossessionPct = d.prcp_BkrTakePossessionPct,
            @ins_prcp_BkrCollectPct = i.prcp_BkrCollectPct, @del_prcp_BkrCollectPct = d.prcp_BkrCollectPct,
            @ins_prcp_BkrTakeFrieght = i.prcp_BkrTakeFrieght, @del_prcp_BkrTakeFrieght = d.prcp_BkrTakeFrieght,
            @ins_prcp_BkrConfirmation = i.prcp_BkrConfirmation, @del_prcp_BkrConfirmation = d.prcp_BkrConfirmation,
            @ins_prcp_BkrReceive = i.prcp_BkrReceive, @del_prcp_BkrReceive = d.prcp_BkrReceive,
            @ins_prcp_BkrGroundInspections = i.prcp_BkrGroundInspections, @del_prcp_BkrGroundInspections = d.prcp_BkrGroundInspections,
            @ins_prcp_TrkrDirectHaulsPct = i.prcp_TrkrDirectHaulsPct, @del_prcp_TrkrDirectHaulsPct = d.prcp_TrkrDirectHaulsPct,
            @ins_prcp_TrkrTPHaulsPct = i.prcp_TrkrTPHaulsPct, @del_prcp_TrkrTPHaulsPct = d.prcp_TrkrTPHaulsPct,
            @ins_prcp_TrkrProducePct = i.prcp_TrkrProducePct, @del_prcp_TrkrProducePct = d.prcp_TrkrProducePct,
            @ins_prcp_TrkrOtherColdPct = i.prcp_TrkrOtherColdPct, @del_prcp_TrkrOtherColdPct = d.prcp_TrkrOtherColdPct,
            @ins_prcp_TrkrOtherWarmPct = i.prcp_TrkrOtherWarmPct, @del_prcp_TrkrOtherWarmPct = d.prcp_TrkrOtherWarmPct,
            @ins_prcp_TrkrTeams = i.prcp_TrkrTeams, @del_prcp_TrkrTeams = d.prcp_TrkrTeams,
            @ins_prcp_TrkrTrucksOwned = i.prcp_TrkrTrucksOwned, @del_prcp_TrkrTrucksOwned = d.prcp_TrkrTrucksOwned,
            @ins_prcp_TrkrTrucksLeased = i.prcp_TrkrTrucksLeased, @del_prcp_TrkrTrucksLeased = d.prcp_TrkrTrucksLeased,
            @ins_prcp_TrkrTrailersOwned = i.prcp_TrkrTrailersOwned, @del_prcp_TrkrTrailersOwned = d.prcp_TrkrTrailersOwned,
            @ins_prcp_TrkrTrailersLeased = i.prcp_TrkrTrailersLeased, @del_prcp_TrkrTrailersLeased = d.prcp_TrkrTrailersLeased,
            @ins_prcp_TrkrPowerUnits = i.prcp_TrkrPowerUnits, @del_prcp_TrkrPowerUnits = d.prcp_TrkrPowerUnits,
            @ins_prcp_TrkrReefer = i.prcp_TrkrReefer, @del_prcp_TrkrReefer = d.prcp_TrkrReefer,
            @ins_prcp_TrkrDryVan = i.prcp_TrkrDryVan, @del_prcp_TrkrDryVan = d.prcp_TrkrDryVan,
            @ins_prcp_TrkrFlatbed = i.prcp_TrkrFlatbed, @del_prcp_TrkrFlatbed = d.prcp_TrkrFlatbed,
            @ins_prcp_TrkrPiggyback = i.prcp_TrkrPiggyback, @del_prcp_TrkrPiggyback = d.prcp_TrkrPiggyback,
            @ins_prcp_TrkrTanker = i.prcp_TrkrTanker, @del_prcp_TrkrTanker = d.prcp_TrkrTanker,
            @ins_prcp_TrkrContainer = i.prcp_TrkrContainer, @del_prcp_TrkrContainer = d.prcp_TrkrContainer,
            @ins_prcp_TrkrOther = i.prcp_TrkrOther, @del_prcp_TrkrOther = d.prcp_TrkrOther,
            @ins_prcp_TrkrLiabilityAmount = i.prcp_TrkrLiabilityAmount, @del_prcp_TrkrLiabilityAmount = d.prcp_TrkrLiabilityAmount,
            @ins_prcp_TrkrCargoAmount = i.prcp_TrkrCargoAmount, @del_prcp_TrkrCargoAmount = d.prcp_TrkrCargoAmount,
            @ins_prcp_StorageWarehouses = i.prcp_StorageWarehouses, @del_prcp_StorageWarehouses = d.prcp_StorageWarehouses,
            @ins_prcp_StorageSF = i.prcp_StorageSF, @del_prcp_StorageSF = d.prcp_StorageSF,
            @ins_prcp_StorageCF = i.prcp_StorageCF, @del_prcp_StorageCF = d.prcp_StorageCF,
            @ins_prcp_StorageBushel = i.prcp_StorageBushel, @del_prcp_StorageBushel = d.prcp_StorageBushel,
            @ins_prcp_StorageCarlots = i.prcp_StorageCarlots, @del_prcp_StorageCarlots = d.prcp_StorageCarlots,
            @ins_prcp_ColdStorage = i.prcp_ColdStorage, @del_prcp_ColdStorage = d.prcp_ColdStorage,
            @ins_prcp_RipeningStorage = i.prcp_RipeningStorage, @del_prcp_RipeningStorage = d.prcp_RipeningStorage,
            @ins_prcp_HumidityStorage = i.prcp_HumidityStorage, @del_prcp_HumidityStorage = d.prcp_HumidityStorage,
            @ins_prcp_AtmosphereStorage = i.prcp_AtmosphereStorage, @del_prcp_AtmosphereStorage = d.prcp_AtmosphereStorage,
            @ins_prcp_HAACP = i.prcp_HAACP, @del_prcp_HAACP = d.prcp_HAACP,
            @ins_prcp_HAACPCertifiedBy = i.prcp_HAACPCertifiedBy, @del_prcp_HAACPCertifiedBy = d.prcp_HAACPCertifiedBy,
            @ins_prcp_QTV = i.prcp_QTV, @del_prcp_QTV = d.prcp_QTV,
            @ins_prcp_QTVCertifiedBy = i.prcp_QTVCertifiedBy, @del_prcp_QTVCertifiedBy = d.prcp_QTVCertifiedBy,
            @ins_prcp_Organic = i.prcp_Organic, @del_prcp_Organic = d.prcp_Organic,
            @ins_prcp_OrganicCertifiedBy = i.prcp_OrganicCertifiedBy, @del_prcp_OrganicCertifiedBy = d.prcp_OrganicCertifiedBy,
            @ins_prcp_OtherCertification = i.prcp_OtherCertification, @del_prcp_OtherCertification = d.prcp_OtherCertification,
            @ins_prcp_SellFoodWholesaler = i.prcp_SellFoodWholesaler, @del_prcp_SellFoodWholesaler = d.prcp_SellFoodWholesaler,
            @ins_prcp_SellRetailGrocery = i.prcp_SellRetailGrocery, @del_prcp_SellRetailGrocery = d.prcp_SellRetailGrocery,
            @ins_prcp_SellInstitutions = i.prcp_SellInstitutions, @del_prcp_SellInstitutions = d.prcp_SellInstitutions,
            @ins_prcp_SellRestaurants = i.prcp_SellRestaurants, @del_prcp_SellRestaurants = d.prcp_SellRestaurants,
            @ins_prcp_SellMilitary = i.prcp_SellMilitary, @del_prcp_SellMilitary = d.prcp_SellMilitary,
            @ins_prcp_SellDistributors = i.prcp_SellDistributors, @del_prcp_SellDistributors = d.prcp_SellDistributors
        FROM Inserted i
        INNER JOIN deleted d ON i.prcp_CompanyProfileId = d.prcp_CompanyProfileId

        -- prcp_CorporateStructure
        IF  (  Update(prcp_CorporateStructure))
        BEGIN
            SET @OldValue =  @del_prcp_CorporateStructure
            SET @NewValue =  @ins_prcp_CorporateStructure
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_CorporateStructure', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_Volume
        IF  (  Update(prcp_Volume))
        BEGIN
            SET @OldValue =  @del_prcp_Volume
            SET @NewValue =  @ins_prcp_Volume
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_Volume', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_FTEmployees
        IF  (  Update(prcp_FTEmployees))
        BEGIN
            SET @OldValue =  @del_prcp_FTEmployees
            SET @NewValue =  @ins_prcp_FTEmployees
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_FTEmployees', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_PTEmployees
        IF  (  Update(prcp_PTEmployees))
        BEGIN
            SET @OldValue =  @del_prcp_PTEmployees
            SET @NewValue =  @ins_prcp_PTEmployees
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_PTEmployees', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyBrokersPct
        IF  (  Update(prcp_SrcBuyBrokersPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_SrcBuyBrokersPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_SrcBuyBrokersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyBrokersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyWholesalePct
        IF  (  Update(prcp_SrcBuyWholesalePct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_SrcBuyWholesalePct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_SrcBuyWholesalePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyWholesalePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyShippersPct
        IF  (  Update(prcp_SrcBuyShippersPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_SrcBuyShippersPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_SrcBuyShippersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyShippersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyExportersPct
        IF  (  Update(prcp_SrcBuyExportersPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_SrcBuyExportersPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_SrcBuyExportersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyExportersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellBrokersPct
        IF  (  Update(prcp_SellBrokersPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_SellBrokersPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_SellBrokersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellBrokersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellWholesalePct
        IF  (  Update(prcp_SellWholesalePct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_SellWholesalePct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_SellWholesalePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellWholesalePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellDomesticBuyersPct
        IF  (  Update(prcp_SellDomesticBuyersPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_SellDomesticBuyersPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_SellDomesticBuyersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellDomesticBuyersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellExportersPct
        IF  (  Update(prcp_SellExportersPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_SellExportersPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_SellExportersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellExportersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellBuyOthers
        IF  (  Update(prcp_SellBuyOthers))
        BEGIN
            SET @OldValue =  @del_prcp_SellBuyOthers
            SET @NewValue =  @ins_prcp_SellBuyOthers
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellBuyOthers', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellDomesticAccountTypes
        IF  (  Update(prcp_SellDomesticAccountTypes))
        BEGIN
            SET @OldValue =  @del_prcp_SellDomesticAccountTypes
            SET @NewValue =  @ins_prcp_SellDomesticAccountTypes
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellDomesticAccountTypes', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrTakeTitlePct
        IF  (  Update(prcp_BkrTakeTitlePct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_BkrTakeTitlePct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_BkrTakeTitlePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrTakeTitlePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrTakePossessionPct
        IF  (  Update(prcp_BkrTakePossessionPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_BkrTakePossessionPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_BkrTakePossessionPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrTakePossessionPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrCollectPct
        IF  (  Update(prcp_BkrCollectPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_BkrCollectPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_BkrCollectPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrCollectPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrTakeFrieght
        IF  (  Update(prcp_BkrTakeFrieght))
        BEGIN
            SET @OldValue =  @del_prcp_BkrTakeFrieght
            SET @NewValue =  @ins_prcp_BkrTakeFrieght
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrTakeFrieght', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrConfirmation
        IF  (  Update(prcp_BkrConfirmation))
        BEGIN
            SET @OldValue =  @del_prcp_BkrConfirmation
            SET @NewValue =  @ins_prcp_BkrConfirmation
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrConfirmation', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrReceive
        IF  (  Update(prcp_BkrReceive))
        BEGIN
            SET @OldValue =  @del_prcp_BkrReceive
            SET @NewValue =  @ins_prcp_BkrReceive
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrReceive', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrGroundInspections
        IF  (  Update(prcp_BkrGroundInspections))
        BEGIN
            SET @OldValue =  @del_prcp_BkrGroundInspections
            SET @NewValue =  @ins_prcp_BkrGroundInspections
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrGroundInspections', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrDirectHaulsPct
        IF  (  Update(prcp_TrkrDirectHaulsPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_TrkrDirectHaulsPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_TrkrDirectHaulsPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrDirectHaulsPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTPHaulsPct
        IF  (  Update(prcp_TrkrTPHaulsPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_TrkrTPHaulsPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_TrkrTPHaulsPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTPHaulsPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrProducePct
        IF  (  Update(prcp_TrkrProducePct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_TrkrProducePct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_TrkrProducePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrProducePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrOtherColdPct
        IF  (  Update(prcp_TrkrOtherColdPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_TrkrOtherColdPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_TrkrOtherColdPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrOtherColdPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrOtherWarmPct
        IF  (  Update(prcp_TrkrOtherWarmPct))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_TrkrOtherWarmPct)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_TrkrOtherWarmPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrOtherWarmPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTeams
        IF  (  Update(prcp_TrkrTeams))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrTeams
            SET @NewValue =  @ins_prcp_TrkrTeams
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTeams', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTrucksOwned
        IF  (  Update(prcp_TrkrTrucksOwned))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrTrucksOwned
            SET @NewValue =  @ins_prcp_TrkrTrucksOwned
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTrucksOwned', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTrucksLeased
        IF  (  Update(prcp_TrkrTrucksLeased))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrTrucksLeased
            SET @NewValue =  @ins_prcp_TrkrTrucksLeased
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTrucksLeased', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTrailersOwned
        IF  (  Update(prcp_TrkrTrailersOwned))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrTrailersOwned
            SET @NewValue =  @ins_prcp_TrkrTrailersOwned
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTrailersOwned', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTrailersLeased
        IF  (  Update(prcp_TrkrTrailersLeased))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrTrailersLeased
            SET @NewValue =  @ins_prcp_TrkrTrailersLeased
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTrailersLeased', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrPowerUnits
        IF  (  Update(prcp_TrkrPowerUnits))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrPowerUnits
            SET @NewValue =  @ins_prcp_TrkrPowerUnits
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrPowerUnits', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrReefer
        IF  (  Update(prcp_TrkrReefer))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrReefer
            SET @NewValue =  @ins_prcp_TrkrReefer
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrReefer', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrDryVan
        IF  (  Update(prcp_TrkrDryVan))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrDryVan
            SET @NewValue =  @ins_prcp_TrkrDryVan
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrDryVan', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrFlatbed
        IF  (  Update(prcp_TrkrFlatbed))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrFlatbed
            SET @NewValue =  @ins_prcp_TrkrFlatbed
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrFlatbed', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrPiggyback
        IF  (  Update(prcp_TrkrPiggyback))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrPiggyback
            SET @NewValue =  @ins_prcp_TrkrPiggyback
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrPiggyback', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTanker
        IF  (  Update(prcp_TrkrTanker))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrTanker
            SET @NewValue =  @ins_prcp_TrkrTanker
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTanker', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrContainer
        IF  (  Update(prcp_TrkrContainer))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrContainer
            SET @NewValue =  @ins_prcp_TrkrContainer
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrContainer', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrOther
        IF  (  Update(prcp_TrkrOther))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrOther
            SET @NewValue =  @ins_prcp_TrkrOther
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrOther', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrLiabilityAmount
        IF  (  Update(prcp_TrkrLiabilityAmount))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_TrkrLiabilityAmount)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_TrkrLiabilityAmount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrLiabilityAmount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrCargoAmount
        IF  (  Update(prcp_TrkrCargoAmount))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_TrkrCargoAmount)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_TrkrCargoAmount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrCargoAmount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageWarehouses
        IF  (  Update(prcp_StorageWarehouses))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prcp_StorageWarehouses)
            SET @NewValue =  convert(varchar(3000), @ins_prcp_StorageWarehouses)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageWarehouses', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageSF
        IF  (  Update(prcp_StorageSF))
        BEGIN
            SET @OldValue =  @del_prcp_StorageSF
            SET @NewValue =  @ins_prcp_StorageSF
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageSF', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageCF
        IF  (  Update(prcp_StorageCF))
        BEGIN
            SET @OldValue =  @del_prcp_StorageCF
            SET @NewValue =  @ins_prcp_StorageCF
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageCF', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageBushel
        IF  (  Update(prcp_StorageBushel))
        BEGIN
            SET @OldValue =  @del_prcp_StorageBushel
            SET @NewValue =  @ins_prcp_StorageBushel
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageBushel', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageCarlots
        IF  (  Update(prcp_StorageCarlots))
        BEGIN
            SET @OldValue =  @del_prcp_StorageCarlots
            SET @NewValue =  @ins_prcp_StorageCarlots
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageCarlots', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_ColdStorage
        IF  (  Update(prcp_ColdStorage))
        BEGIN
            SET @OldValue =  @del_prcp_ColdStorage
            SET @NewValue =  @ins_prcp_ColdStorage
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_ColdStorage', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_RipeningStorage
        IF  (  Update(prcp_RipeningStorage))
        BEGIN
            SET @OldValue =  @del_prcp_RipeningStorage
            SET @NewValue =  @ins_prcp_RipeningStorage
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_RipeningStorage', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_HumidityStorage
        IF  (  Update(prcp_HumidityStorage))
        BEGIN
            SET @OldValue =  @del_prcp_HumidityStorage
            SET @NewValue =  @ins_prcp_HumidityStorage
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_HumidityStorage', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_AtmosphereStorage
        IF  (  Update(prcp_AtmosphereStorage))
        BEGIN
            SET @OldValue =  @del_prcp_AtmosphereStorage
            SET @NewValue =  @ins_prcp_AtmosphereStorage
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_AtmosphereStorage', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_HAACP
        IF  (  Update(prcp_HAACP))
        BEGIN
            SET @OldValue =  @del_prcp_HAACP
            SET @NewValue =  @ins_prcp_HAACP
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_HAACP', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_HAACPCertifiedBy
        IF  (  Update(prcp_HAACPCertifiedBy))
        BEGIN
            SET @OldValue =  @del_prcp_HAACPCertifiedBy
            SET @NewValue =  @ins_prcp_HAACPCertifiedBy
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_HAACPCertifiedBy', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_QTV
        IF  (  Update(prcp_QTV))
        BEGIN
            SET @OldValue =  @del_prcp_QTV
            SET @NewValue =  @ins_prcp_QTV
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_QTV', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_QTVCertifiedBy
        IF  (  Update(prcp_QTVCertifiedBy))
        BEGIN
            SET @OldValue =  @del_prcp_QTVCertifiedBy
            SET @NewValue =  @ins_prcp_QTVCertifiedBy
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_QTVCertifiedBy', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_Organic
        IF  (  Update(prcp_Organic))
        BEGIN
            SET @OldValue =  @del_prcp_Organic
            SET @NewValue =  @ins_prcp_Organic
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_Organic', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_OrganicCertifiedBy
        IF  (  Update(prcp_OrganicCertifiedBy))
        BEGIN
            SET @OldValue =  @del_prcp_OrganicCertifiedBy
            SET @NewValue =  @ins_prcp_OrganicCertifiedBy
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_OrganicCertifiedBy', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_OtherCertification
        IF  (  Update(prcp_OtherCertification))
        BEGIN
            SET @OldValue =  @del_prcp_OtherCertification
            SET @NewValue =  @ins_prcp_OtherCertification
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_OtherCertification', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellFoodWholesaler
        IF  (  Update(prcp_SellFoodWholesaler))
        BEGIN
            SET @OldValue =  @del_prcp_SellFoodWholesaler
            SET @NewValue =  @ins_prcp_SellFoodWholesaler
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellFoodWholesaler', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellRetailGrocery
        IF  (  Update(prcp_SellRetailGrocery))
        BEGIN
            SET @OldValue =  @del_prcp_SellRetailGrocery
            SET @NewValue =  @ins_prcp_SellRetailGrocery
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellRetailGrocery', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellInstitutions
        IF  (  Update(prcp_SellInstitutions))
        BEGIN
            SET @OldValue =  @del_prcp_SellInstitutions
            SET @NewValue =  @ins_prcp_SellInstitutions
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellInstitutions', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellRestaurants
        IF  (  Update(prcp_SellRestaurants))
        BEGIN
            SET @OldValue =  @del_prcp_SellRestaurants
            SET @NewValue =  @ins_prcp_SellRestaurants
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellRestaurants', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellMilitary
        IF  (  Update(prcp_SellMilitary))
        BEGIN
            SET @OldValue =  @del_prcp_SellMilitary
            SET @NewValue =  @ins_prcp_SellMilitary
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellMilitary', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellDistributors
        IF  (  Update(prcp_SellDistributors))
        BEGIN
            SET @OldValue =  @del_prcp_SellDistributors
            SET @NewValue =  @ins_prcp_SellDistributors
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellDistributors', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END


        -- prcp_TrkrLiabilityCarrier
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prcp_TrkrLiabilityCarrier, d.prcp_TrkrLiabilityCarrier
            FROM Inserted i
            INNER JOIN deleted d ON i.prcp_CompanyProfileId = d.prcp_CompanyProfileId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrLiabilityCarrier', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- prcp_TrkrCargoCarrier
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prcp_TrkrCargoCarrier, d.prcp_TrkrCargoCarrier
            FROM Inserted i
            INNER JOIN deleted d ON i.prcp_CompanyProfileId = d.prcp_CompanyProfileId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrCargoCarrier', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable
        DROP TABLE #TextTable
    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRCompanyProfile SET 
        PRCompanyProfile.prcp_CompanyProfileId=i.prcp_CompanyProfileId, 
        PRCompanyProfile.prcp_CreatedBy=i.prcp_CreatedBy, 
        PRCompanyProfile.prcp_CreatedDate=dbo.ufn_GetAccpacDate(i.prcp_CreatedDate), 
        PRCompanyProfile.prcp_UpdatedBy=i.prcp_UpdatedBy, 
        PRCompanyProfile.prcp_UpdatedDate=dbo.ufn_GetAccpacDate(i.prcp_UpdatedDate), 
        PRCompanyProfile.prcp_TimeStamp=dbo.ufn_GetAccpacDate(i.prcp_TimeStamp), 
        PRCompanyProfile.prcp_Deleted=i.prcp_Deleted, 
        PRCompanyProfile.prcp_WorkflowId=i.prcp_WorkflowId, 
        PRCompanyProfile.prcp_Secterr=i.prcp_Secterr, 
        PRCompanyProfile.prcp_CompanyId=i.prcp_CompanyId, 
        PRCompanyProfile.prcp_CorporateStructure=i.prcp_CorporateStructure, 
        PRCompanyProfile.prcp_Volume=i.prcp_Volume, 
        PRCompanyProfile.prcp_FTEmployees=i.prcp_FTEmployees, 
        PRCompanyProfile.prcp_PTEmployees=i.prcp_PTEmployees, 
        PRCompanyProfile.prcp_SrcBuyBrokersPct=i.prcp_SrcBuyBrokersPct, 
        PRCompanyProfile.prcp_SrcBuyWholesalePct=i.prcp_SrcBuyWholesalePct, 
        PRCompanyProfile.prcp_SrcBuyShippersPct=i.prcp_SrcBuyShippersPct, 
        PRCompanyProfile.prcp_SrcBuyExportersPct=i.prcp_SrcBuyExportersPct, 
        PRCompanyProfile.prcp_SellBrokersPct=i.prcp_SellBrokersPct, 
        PRCompanyProfile.prcp_SellWholesalePct=i.prcp_SellWholesalePct, 
        PRCompanyProfile.prcp_SellDomesticBuyersPct=i.prcp_SellDomesticBuyersPct, 
        PRCompanyProfile.prcp_SellExportersPct=i.prcp_SellExportersPct, 
        PRCompanyProfile.prcp_SellBuyOthers=i.prcp_SellBuyOthers, 
        PRCompanyProfile.prcp_SellDomesticAccountTypes=i.prcp_SellDomesticAccountTypes, 
        PRCompanyProfile.prcp_BkrTakeTitlePct=i.prcp_BkrTakeTitlePct, 
        PRCompanyProfile.prcp_BkrTakePossessionPct=i.prcp_BkrTakePossessionPct, 
        PRCompanyProfile.prcp_BkrCollectPct=i.prcp_BkrCollectPct, 
        PRCompanyProfile.prcp_BkrTakeFrieght=i.prcp_BkrTakeFrieght, 
        PRCompanyProfile.prcp_BkrConfirmation=i.prcp_BkrConfirmation, 
        PRCompanyProfile.prcp_BkrReceive=i.prcp_BkrReceive, 
        PRCompanyProfile.prcp_BkrGroundInspections=i.prcp_BkrGroundInspections, 
        PRCompanyProfile.prcp_TrkrDirectHaulsPct=i.prcp_TrkrDirectHaulsPct, 
        PRCompanyProfile.prcp_TrkrTPHaulsPct=i.prcp_TrkrTPHaulsPct, 
        PRCompanyProfile.prcp_TrkrProducePct=i.prcp_TrkrProducePct, 
        PRCompanyProfile.prcp_TrkrOtherColdPct=i.prcp_TrkrOtherColdPct, 
        PRCompanyProfile.prcp_TrkrOtherWarmPct=i.prcp_TrkrOtherWarmPct, 
        PRCompanyProfile.prcp_TrkrTeams=i.prcp_TrkrTeams, 
        PRCompanyProfile.prcp_TrkrTrucksOwned=i.prcp_TrkrTrucksOwned, 
        PRCompanyProfile.prcp_TrkrTrucksLeased=i.prcp_TrkrTrucksLeased, 
        PRCompanyProfile.prcp_TrkrTrailersOwned=i.prcp_TrkrTrailersOwned, 
        PRCompanyProfile.prcp_TrkrTrailersLeased=i.prcp_TrkrTrailersLeased, 
        PRCompanyProfile.prcp_TrkrPowerUnits=i.prcp_TrkrPowerUnits, 
        PRCompanyProfile.prcp_TrkrReefer=i.prcp_TrkrReefer, 
        PRCompanyProfile.prcp_TrkrDryVan=i.prcp_TrkrDryVan, 
        PRCompanyProfile.prcp_TrkrFlatbed=i.prcp_TrkrFlatbed, 
        PRCompanyProfile.prcp_TrkrPiggyback=i.prcp_TrkrPiggyback, 
        PRCompanyProfile.prcp_TrkrTanker=i.prcp_TrkrTanker, 
        PRCompanyProfile.prcp_TrkrContainer=i.prcp_TrkrContainer, 
        PRCompanyProfile.prcp_TrkrOther=i.prcp_TrkrOther, 
        PRCompanyProfile.prcp_TrkrLiabilityAmount=i.prcp_TrkrLiabilityAmount, 
        PRCompanyProfile.prcp_TrkrLiabilityCarrier=i.prcp_TrkrLiabilityCarrier, 
        PRCompanyProfile.prcp_TrkrCargoAmount=i.prcp_TrkrCargoAmount, 
        PRCompanyProfile.prcp_TrkrCargoCarrier=i.prcp_TrkrCargoCarrier, 
        PRCompanyProfile.prcp_StorageWarehouses=i.prcp_StorageWarehouses, 
        PRCompanyProfile.prcp_StorageSF=i.prcp_StorageSF, 
        PRCompanyProfile.prcp_StorageCF=i.prcp_StorageCF, 
        PRCompanyProfile.prcp_StorageBushel=i.prcp_StorageBushel, 
        PRCompanyProfile.prcp_StorageCarlots=i.prcp_StorageCarlots, 
        PRCompanyProfile.prcp_ColdStorage=i.prcp_ColdStorage, 
        PRCompanyProfile.prcp_RipeningStorage=i.prcp_RipeningStorage, 
        PRCompanyProfile.prcp_HumidityStorage=i.prcp_HumidityStorage, 
        PRCompanyProfile.prcp_AtmosphereStorage=i.prcp_AtmosphereStorage, 
        PRCompanyProfile.prcp_HAACP=i.prcp_HAACP, 
        PRCompanyProfile.prcp_HAACPCertifiedBy=i.prcp_HAACPCertifiedBy, 
        PRCompanyProfile.prcp_QTV=i.prcp_QTV, 
        PRCompanyProfile.prcp_QTVCertifiedBy=i.prcp_QTVCertifiedBy, 
        PRCompanyProfile.prcp_Organic=i.prcp_Organic, 
        PRCompanyProfile.prcp_OrganicCertifiedBy=i.prcp_OrganicCertifiedBy, 
        PRCompanyProfile.prcp_OtherCertification=i.prcp_OtherCertification, 
        PRCompanyProfile.prcp_SellFoodWholesaler=i.prcp_SellFoodWholesaler, 
        PRCompanyProfile.prcp_SellRetailGrocery=i.prcp_SellRetailGrocery, 
        PRCompanyProfile.prcp_SellInstitutions=i.prcp_SellInstitutions, 
        PRCompanyProfile.prcp_SellRestaurants=i.prcp_SellRestaurants, 
        PRCompanyProfile.prcp_SellMilitary=i.prcp_SellMilitary, 
        PRCompanyProfile.prcp_SellDistributors=i.prcp_SellDistributors
        FROM inserted i 
          INNER JOIN PRCompanyProfile ON i.prcp_CompanyProfileId=PRCompanyProfile.prcp_CompanyProfileId
    END
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        SELECT @NewValueTemp = prtm_FullMarketName FROM PRTerminalMarket
                WHERE prtm_TerminalMarketId = @prct_TerminalMarketId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prct_TerminalMarketId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

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

        DROP TABLE #TextTable
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = convert(varchar(50), @prli_Number)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

        Declare @ins_pral_Alias nvarchar(50), @del_pral_Alias nvarchar(50)
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

        DROP TABLE #TextTable
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
        PRCompanyAlias.pral_Alias=i.pral_Alias
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), pral_CompanyID int, pral_Alias nvarchar(50))
    INSERT INTO @ProcessTable
        SELECT 'Insert',pral_CompanyID,pral_Alias
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',pral_CompanyID,pral_Alias
        FROM Deleted


    Declare @pral_Alias nvarchar(50)

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
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Update (prra_PayRatingId) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Rating ' + convert(varchar,@prra_RatingId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

        Declare @ins_prra_Date datetime, @del_prra_Date datetime
        Declare @ins_prra_Current nchar(1), @del_prra_Current nchar(1)
        Declare @ins_prra_CreditWorthId int, @del_prra_CreditWorthId int
        Declare @ins_prra_IntegrityId int, @del_prra_IntegrityId int
        Declare @ins_prra_PayRatingId int, @del_prra_PayRatingId int
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prra_Date = i.prra_Date, @del_prra_Date = d.prra_Date,
            @ins_prra_Current = i.prra_Current, @del_prra_Current = d.prra_Current,
            @ins_prra_CreditWorthId = i.prra_CreditWorthId, @del_prra_CreditWorthId = d.prra_CreditWorthId,
            @ins_prra_IntegrityId = i.prra_IntegrityId, @del_prra_IntegrityId = d.prra_IntegrityId,
            @ins_prra_PayRatingId = i.prra_PayRatingId, @del_prra_PayRatingId = d.prra_PayRatingId
        FROM Inserted i
        INNER JOIN deleted d ON i.prra_RatingId = d.prra_RatingId

        -- prra_Date
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prra_Date, @ins_prra_Date) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prra_Date IS NOT NULL AND convert(varchar,@del_prra_Date,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(3000), @del_prra_Date)
            IF (@ins_prra_Date IS NOT NULL AND convert(varchar,@ins_prra_Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_prra_Date)
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
            SELECT @NewValueTemp = prcw_Name FROM PRCreditWorthRating
                WHERE prcw_CreditWorthRatingId = @ins_prra_CreditWorthId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_prra_CreditWorthId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prcw_Name FROM PRCreditWorthRating
                WHERE prcw_CreditWorthRatingId = @del_prra_CreditWorthId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_prra_CreditWorthId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_CreditWorthId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prra_IntegrityId
        IF  (  Update(prra_IntegrityId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prin_Name FROM PRIntegrityRating
                WHERE prin_IntegrityRatingId = @ins_prra_IntegrityId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_prra_IntegrityId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prin_Name FROM PRIntegrityRating
                WHERE prin_IntegrityRatingId = @del_prra_IntegrityId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_prra_IntegrityId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_IntegrityId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prra_PayRatingId
        IF  (  Update(prra_PayRatingId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prpy_Name FROM PRPayRating
                WHERE prpy_PayRatingId = @ins_prra_PayRatingId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_prra_PayRatingId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prpy_Name FROM PRPayRating
                WHERE prpy_PayRatingId = @del_prra_PayRatingId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_prra_PayRatingId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_PayRatingId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END


        -- prra_InternalAnalysis
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prra_InternalAnalysis, d.prra_InternalAnalysis
            FROM Inserted i
            INNER JOIN deleted d ON i.prra_RatingId = d.prra_RatingId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_InternalAnalysis', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- prra_PublishedAnalysis
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prra_PublishedAnalysis, d.prra_PublishedAnalysis
            FROM Inserted i
            INNER JOIN deleted d ON i.prra_RatingId = d.prra_RatingId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 'prra_PublishedAnalysis', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable
        DROP TABLE #TextTable
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
        PRRating.prra_PublishedAnalysis=i.prra_PublishedAnalysis
        FROM inserted i 
          INNER JOIN PRRating ON i.prra_RatingId=PRRating.prra_RatingId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_PRRating_insdel
 * 
 * Table:  PRRating
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRRating_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRRating_insdel]
GO

CREATE TRIGGER dbo.trg_PRRating_insdel
ON PRRating
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
    Declare @prra_RatingId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prra_CompanyID int, prra_Date datetime, prra_CreditWorthId int, prra_IntegrityId int, prra_PayRatingId int)
    INSERT INTO @ProcessTable
        SELECT 'Insert',prra_CompanyID,prra_Date,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prra_CompanyID,prra_Date,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId
        FROM Deleted


    Declare @prra_Date datetime
    Declare @prra_CreditWorthId int
    Declare @prra_IntegrityId int
    Declare @prra_PayRatingId int

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prra_CompanyID,prra_Date,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prra_Date,@prra_CreditWorthId,@prra_IntegrityId,@prra_PayRatingId
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
            SET @Msg = 'Changes Failed.  Rating ' + convert(varchar,@prra_RatingId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = convert(varchar(50), @prra_Date)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prcw_Name FROM PRCreditWorthRating
                WHERE prcw_CreditWorthRatingId = @prra_CreditWorthId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prra_CreditWorthId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prin_Name FROM PRIntegrityRating
                WHERE prin_IntegrityRatingId = @prra_IntegrityId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prra_IntegrityId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = prpy_Name FROM PRPayRating
                WHERE prpy_PayRatingId = @prra_PayRatingId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prra_PayRatingId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Rating', @Action, 
            'prra_Date,prcw_Name,prin_Name,prpy_Name', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prra_Date,@prra_CreditWorthId,@prra_IntegrityId,@prra_PayRatingId
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        SELECT @NewValueTemp = prrn_Name FROM PRRatingNumeral
                WHERE prrn_RatingNumeralId = @pran_RatingNumeralId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @pran_RatingNumeralId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Update (pers_PRDefaultEmailId) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Person ' + convert(varchar,@pers_PersonId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

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
        Declare @ins_pers_PRDefaultEmailId int, @del_pers_PRDefaultEmailId int
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
            @ins_pers_PRDefaultEmailId = i.pers_PRDefaultEmailId, @del_pers_PRDefaultEmailId = d.pers_PRDefaultEmailId
        FROM Inserted i
        INNER JOIN deleted d ON i.pers_PersonId = d.pers_PersonId

        -- Pers_PrimaryAddressId
        IF  (  Update(Pers_PrimaryAddressId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = addr_Address1 FROM Address
                WHERE addr_AddressId = @ins_Pers_PrimaryAddressId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_Pers_PrimaryAddressId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = addr_Address1 FROM Address
                WHERE addr_AddressId = @del_Pers_PrimaryAddressId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_Pers_PrimaryAddressId))

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
            SET @OldValue =  @del_pers_PRLanguageSpoken
            SET @NewValue =  @ins_pers_PRLanguageSpoken
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
        -- pers_PRDefaultEmailId
        IF  (  Update(pers_PRDefaultEmailId))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_pers_PRDefaultEmailId)
            SET @NewValue =  convert(varchar(3000), @ins_pers_PRDefaultEmailId)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRDefaultEmailId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END


        -- pers_PRNotes
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.pers_PRNotes, d.pers_PRNotes
            FROM Inserted i
            INNER JOIN deleted d ON i.pers_PersonId = d.pers_PersonId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person', @Action, 'pers_PRNotes', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable
        DROP TABLE #TextTable
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
        Person.Pers_PhoneCountryCode=i.Pers_PhoneCountryCode, 
        Person.Pers_PhoneAreaCode=i.Pers_PhoneAreaCode, 
        Person.Pers_PhoneNumber=i.Pers_PhoneNumber, 
        Person.Pers_EmailAddress=i.Pers_EmailAddress, 
        Person.Pers_FaxCountryCode=i.Pers_FaxCountryCode, 
        Person.Pers_FaxAreaCode=i.Pers_FaxAreaCode, 
        Person.Pers_FaxNumber=i.Pers_FaxNumber, 
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
        Person.pers_PRDefaultEmailId=i.pers_PRDefaultEmailId
        FROM inserted i 
          INNER JOIN Person ON i.pers_PersonId=Person.pers_PersonId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_Person_Link_ioupd
 * 
 * Table:  Person_Link
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Person_Link_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Person_Link_ioupd]
GO

CREATE TRIGGER dbo.trg_Person_Link_ioupd
ON Person_Link
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
    Declare @peli_PersonLinkId int
    Declare @UserId int
    Declare @PersonId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.peli_PersonId, @UserId = i.peli_UpdatedBy, @peli_PersonLinkId = i.peli_PersonLinkId
        FROM Inserted i
        INNER JOIN deleted d ON i.peli_PersonLinkId = d.peli_PersonLinkId
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
        Update (peli_PRTitleCode) OR
        Update (peli_PRDLTitle) OR
        Update (peli_PRTitle) OR
        Update (peli_PRResponsibilities) OR
        Update (peli_PRPctOwned) OR
        Update (peli_PREBBPublish) OR
        Update (peli_PRBRPublish) OR
        Update (peli_PRExitReason) OR
        Update (peli_PRRatingLine) OR
        Update (peli_PRStartDate) OR
        Update (peli_PREndDate) OR
        Update (peli_PRStatus) OR
        Update (peli_PRCompanyId) OR
        Update (peli_PRRole) OR
        Update (peli_PRRecipientRole) OR
        Update (peli_PROwnershipRole) OR
        Update (peli_WebStatus) OR
        Update (peli_WebPassword) OR
        Update (peli_PRAUSReceiveMethod) OR
        Update (peli_PRAUSChangePreference) OR
        Update (peli_PRReceivesBBScoreReport) OR
        Update (peli_PRWhenVisited) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  History ' + convert(varchar,@peli_PersonLinkId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

        Declare @ins_peli_PRTitleCode nvarchar(40), @del_peli_PRTitleCode nvarchar(40)
        Declare @ins_peli_PRDLTitle nvarchar(30), @del_peli_PRDLTitle nvarchar(30)
        Declare @ins_peli_PRTitle nvarchar(30), @del_peli_PRTitle nvarchar(30)
        Declare @ins_peli_PRResponsibilities nvarchar(75), @del_peli_PRResponsibilities nvarchar(75)
        Declare @ins_peli_PRPctOwned numeric, @del_peli_PRPctOwned numeric
        Declare @ins_peli_PREBBPublish nchar(1), @del_peli_PREBBPublish nchar(1)
        Declare @ins_peli_PRBRPublish nchar(1), @del_peli_PRBRPublish nchar(1)
        Declare @ins_peli_PRExitReason nvarchar(75), @del_peli_PRExitReason nvarchar(75)
        Declare @ins_peli_PRRatingLine nvarchar(50), @del_peli_PRRatingLine nvarchar(50)
        Declare @ins_peli_PRStartDate nvarchar(25), @del_peli_PRStartDate nvarchar(25)
        Declare @ins_peli_PREndDate nvarchar(25), @del_peli_PREndDate nvarchar(25)
        Declare @ins_peli_PRStatus nvarchar(40), @del_peli_PRStatus nvarchar(40)
        Declare @ins_peli_PRCompanyId int, @del_peli_PRCompanyId int
        Declare @ins_peli_PRRole nvarchar(255), @del_peli_PRRole nvarchar(255)
        Declare @ins_peli_PRRecipientRole nvarchar(40), @del_peli_PRRecipientRole nvarchar(40)
        Declare @ins_peli_PROwnershipRole nvarchar(40), @del_peli_PROwnershipRole nvarchar(40)
        Declare @ins_peli_WebStatus nvarchar(1), @del_peli_WebStatus nvarchar(1)
        Declare @ins_peli_WebPassword nvarchar(8), @del_peli_WebPassword nvarchar(8)
        Declare @ins_peli_PRAUSReceiveMethod nvarchar(40), @del_peli_PRAUSReceiveMethod nvarchar(40)
        Declare @ins_peli_PRAUSChangePreference nvarchar(40), @del_peli_PRAUSChangePreference nvarchar(40)
        Declare @ins_peli_PRReceivesBBScoreReport nchar(1), @del_peli_PRReceivesBBScoreReport nchar(1)
        Declare @ins_peli_PRWhenVisited nvarchar(50), @del_peli_PRWhenVisited nvarchar(50)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_peli_PRTitleCode = i.peli_PRTitleCode, @del_peli_PRTitleCode = d.peli_PRTitleCode,
            @ins_peli_PRDLTitle = i.peli_PRDLTitle, @del_peli_PRDLTitle = d.peli_PRDLTitle,
            @ins_peli_PRTitle = i.peli_PRTitle, @del_peli_PRTitle = d.peli_PRTitle,
            @ins_peli_PRResponsibilities = i.peli_PRResponsibilities, @del_peli_PRResponsibilities = d.peli_PRResponsibilities,
            @ins_peli_PRPctOwned = i.peli_PRPctOwned, @del_peli_PRPctOwned = d.peli_PRPctOwned,
            @ins_peli_PREBBPublish = i.peli_PREBBPublish, @del_peli_PREBBPublish = d.peli_PREBBPublish,
            @ins_peli_PRBRPublish = i.peli_PRBRPublish, @del_peli_PRBRPublish = d.peli_PRBRPublish,
            @ins_peli_PRExitReason = i.peli_PRExitReason, @del_peli_PRExitReason = d.peli_PRExitReason,
            @ins_peli_PRRatingLine = i.peli_PRRatingLine, @del_peli_PRRatingLine = d.peli_PRRatingLine,
            @ins_peli_PRStartDate = i.peli_PRStartDate, @del_peli_PRStartDate = d.peli_PRStartDate,
            @ins_peli_PREndDate = i.peli_PREndDate, @del_peli_PREndDate = d.peli_PREndDate,
            @ins_peli_PRStatus = i.peli_PRStatus, @del_peli_PRStatus = d.peli_PRStatus,
            @ins_peli_PRCompanyId = i.peli_PRCompanyId, @del_peli_PRCompanyId = d.peli_PRCompanyId,
            @ins_peli_PRRole = i.peli_PRRole, @del_peli_PRRole = d.peli_PRRole,
            @ins_peli_PRRecipientRole = i.peli_PRRecipientRole, @del_peli_PRRecipientRole = d.peli_PRRecipientRole,
            @ins_peli_PROwnershipRole = i.peli_PROwnershipRole, @del_peli_PROwnershipRole = d.peli_PROwnershipRole,
            @ins_peli_WebStatus = i.peli_WebStatus, @del_peli_WebStatus = d.peli_WebStatus,
            @ins_peli_WebPassword = i.peli_WebPassword, @del_peli_WebPassword = d.peli_WebPassword,
            @ins_peli_PRAUSReceiveMethod = i.peli_PRAUSReceiveMethod, @del_peli_PRAUSReceiveMethod = d.peli_PRAUSReceiveMethod,
            @ins_peli_PRAUSChangePreference = i.peli_PRAUSChangePreference, @del_peli_PRAUSChangePreference = d.peli_PRAUSChangePreference,
            @ins_peli_PRReceivesBBScoreReport = i.peli_PRReceivesBBScoreReport, @del_peli_PRReceivesBBScoreReport = d.peli_PRReceivesBBScoreReport,
            @ins_peli_PRWhenVisited = i.peli_PRWhenVisited, @del_peli_PRWhenVisited = d.peli_PRWhenVisited
        FROM Inserted i
        INNER JOIN deleted d ON i.peli_PersonLinkId = d.peli_PersonLinkId

        -- peli_PRTitleCode
        IF  (  Update(peli_PRTitleCode))
        BEGIN
            SET @OldValue =  @del_peli_PRTitleCode
            SET @NewValue =  @ins_peli_PRTitleCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRTitleCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRDLTitle
        IF  (  Update(peli_PRDLTitle))
        BEGIN
            SET @OldValue =  @del_peli_PRDLTitle
            SET @NewValue =  @ins_peli_PRDLTitle
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRDLTitle', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRTitle
        IF  (  Update(peli_PRTitle))
        BEGIN
            SET @OldValue =  @del_peli_PRTitle
            SET @NewValue =  @ins_peli_PRTitle
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRTitle', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRResponsibilities
        IF  (  Update(peli_PRResponsibilities))
        BEGIN
            SET @OldValue =  @del_peli_PRResponsibilities
            SET @NewValue =  @ins_peli_PRResponsibilities
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRResponsibilities', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRPctOwned
        IF  (  Update(peli_PRPctOwned))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_peli_PRPctOwned)
            SET @NewValue =  convert(varchar(3000), @ins_peli_PRPctOwned)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRPctOwned', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PREBBPublish
        IF  (  Update(peli_PREBBPublish))
        BEGIN
            SET @OldValue =  @del_peli_PREBBPublish
            SET @NewValue =  @ins_peli_PREBBPublish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PREBBPublish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRBRPublish
        IF  (  Update(peli_PRBRPublish))
        BEGIN
            SET @OldValue =  @del_peli_PRBRPublish
            SET @NewValue =  @ins_peli_PRBRPublish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRBRPublish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRExitReason
        IF  (  Update(peli_PRExitReason))
        BEGIN
            SET @OldValue =  @del_peli_PRExitReason
            SET @NewValue =  @ins_peli_PRExitReason
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRExitReason', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRRatingLine
        IF  (  Update(peli_PRRatingLine))
        BEGIN
            SET @OldValue =  @del_peli_PRRatingLine
            SET @NewValue =  @ins_peli_PRRatingLine
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRRatingLine', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRStartDate
        IF  (  Update(peli_PRStartDate))
        BEGIN
            SET @OldValue =  @del_peli_PRStartDate
            SET @NewValue =  @ins_peli_PRStartDate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRStartDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PREndDate
        IF  (  Update(peli_PREndDate))
        BEGIN
            SET @OldValue =  @del_peli_PREndDate
            SET @NewValue =  @ins_peli_PREndDate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PREndDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRStatus
        IF  (  Update(peli_PRStatus))
        BEGIN
            SET @OldValue =  @del_peli_PRStatus
            SET @NewValue =  @ins_peli_PRStatus
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRStatus', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRCompanyId
        IF  (  Update(peli_PRCompanyId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM Company
                WHERE comp_companyid = @ins_peli_PRCompanyId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_peli_PRCompanyId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM Company
                WHERE comp_companyid = @del_peli_PRCompanyId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_peli_PRCompanyId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRCompanyId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRRole
        IF  (  Update(peli_PRRole))
        BEGIN
            SET @OldValue =  @del_peli_PRRole
            SET @NewValue =  @ins_peli_PRRole
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRRole', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRRecipientRole
        IF  (  Update(peli_PRRecipientRole))
        BEGIN
            SET @OldValue =  @del_peli_PRRecipientRole
            SET @NewValue =  @ins_peli_PRRecipientRole
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRRecipientRole', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PROwnershipRole
        IF  (  Update(peli_PROwnershipRole))
        BEGIN
            SET @OldValue =  @del_peli_PROwnershipRole
            SET @NewValue =  @ins_peli_PROwnershipRole
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PROwnershipRole', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_WebStatus
        IF  (  Update(peli_WebStatus))
        BEGIN
            SET @OldValue =  @del_peli_WebStatus
            SET @NewValue =  @ins_peli_WebStatus
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_WebStatus', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_WebPassword
        IF  (  Update(peli_WebPassword))
        BEGIN
            SET @OldValue =  @del_peli_WebPassword
            SET @NewValue =  @ins_peli_WebPassword
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_WebPassword', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRAUSReceiveMethod
        IF  (  Update(peli_PRAUSReceiveMethod))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='peli_PRAUSReceiveMethod' AND capt_code = @ins_peli_PRAUSReceiveMethod
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_peli_PRAUSReceiveMethod)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='peli_PRAUSReceiveMethod' AND capt_code = @del_peli_PRAUSReceiveMethod
            SET @OldValue = COALESCE(@NewValueTemp,  @del_peli_PRAUSReceiveMethod)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRAUSReceiveMethod', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRAUSChangePreference
        IF  (  Update(peli_PRAUSChangePreference))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='peli_PRAUSChangePreference' AND capt_code = @ins_peli_PRAUSChangePreference
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_peli_PRAUSChangePreference)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='peli_PRAUSChangePreference' AND capt_code = @del_peli_PRAUSChangePreference
            SET @OldValue = COALESCE(@NewValueTemp,  @del_peli_PRAUSChangePreference)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRAUSChangePreference', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRReceivesBBScoreReport
        IF  (  Update(peli_PRReceivesBBScoreReport))
        BEGIN
            SET @OldValue =  @del_peli_PRReceivesBBScoreReport
            SET @NewValue =  @ins_peli_PRReceivesBBScoreReport
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRReceivesBBScoreReport', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRWhenVisited
        IF  (  Update(peli_PRWhenVisited))
        BEGIN
            SET @OldValue =  @del_peli_PRWhenVisited
            SET @NewValue =  @ins_peli_PRWhenVisited
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 'peli_PRWhenVisited', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        DROP TABLE #TextTable
    END
    IF (@Err = 0) 
    BEGIN
        UPDATE Person_Link SET 
        Person_Link.PeLi_PersonLinkId=i.PeLi_PersonLinkId, 
        Person_Link.PeLi_PersonId=i.PeLi_PersonId, 
        Person_Link.PeLi_CompanyID=i.PeLi_CompanyID, 
        Person_Link.PeLi_Type=i.PeLi_Type, 
        Person_Link.PeLi_CreatedBy=i.PeLi_CreatedBy, 
        Person_Link.PeLi_CreatedDate=dbo.ufn_GetAccpacDate(i.PeLi_CreatedDate), 
        Person_Link.PeLi_UpdatedBy=i.PeLi_UpdatedBy, 
        Person_Link.PeLi_UpdatedDate=dbo.ufn_GetAccpacDate(i.PeLi_UpdatedDate), 
        Person_Link.PeLi_TimeStamp=dbo.ufn_GetAccpacDate(i.PeLi_TimeStamp), 
        Person_Link.PeLi_Deleted=i.PeLi_Deleted, 
        Person_Link.peli_PRTitleCode=i.peli_PRTitleCode, 
        Person_Link.peli_PRDLTitle=i.peli_PRDLTitle, 
        Person_Link.peli_PRTitle=i.peli_PRTitle, 
        Person_Link.peli_PRResponsibilities=i.peli_PRResponsibilities, 
        Person_Link.peli_PRPctOwned=i.peli_PRPctOwned, 
        Person_Link.peli_PREBBPublish=i.peli_PREBBPublish, 
        Person_Link.peli_PRBRPublish=i.peli_PRBRPublish, 
        Person_Link.peli_PRExitReason=i.peli_PRExitReason, 
        Person_Link.peli_PRRatingLine=i.peli_PRRatingLine, 
        Person_Link.peli_PRStartDate=i.peli_PRStartDate, 
        Person_Link.peli_PREndDate=i.peli_PREndDate, 
        Person_Link.peli_PRStatus=i.peli_PRStatus, 
        Person_Link.peli_PRCompanyId=i.peli_PRCompanyId, 
        Person_Link.peli_PRRole=i.peli_PRRole, 
        Person_Link.peli_PRRecipientRole=i.peli_PRRecipientRole, 
        Person_Link.peli_PROwnershipRole=i.peli_PROwnershipRole, 
        Person_Link.peli_WebStatus=i.peli_WebStatus, 
        Person_Link.peli_WebPassword=i.peli_WebPassword, 
        Person_Link.peli_PRAUSReceiveMethod=i.peli_PRAUSReceiveMethod, 
        Person_Link.peli_PRAUSChangePreference=i.peli_PRAUSChangePreference, 
        Person_Link.peli_PRReceivesBBScoreReport=i.peli_PRReceivesBBScoreReport, 
        Person_Link.peli_PRWhenVisited=i.peli_PRWhenVisited
        FROM inserted i 
          INNER JOIN Person_Link ON i.peli_PersonLinkId=Person_Link.peli_PersonLinkId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_Person_Link_insdel
 * 
 * Table:  Person_Link
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Person_Link_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Person_Link_insdel]
GO

CREATE TRIGGER dbo.trg_Person_Link_insdel
ON Person_Link
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
    Declare @peli_PersonLinkId int
    Declare @UserId int
    Declare @PersonId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), peli_PersonId int, peli_PRTitleCode nvarchar(40), peli_PRCompanyId int)
    INSERT INTO @ProcessTable
        SELECT 'Insert',peli_PersonId,peli_PRTitleCode,peli_PRCompanyId
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',peli_PersonId,peli_PRTitleCode,peli_PRCompanyId
        FROM Deleted


    Declare @peli_PRTitleCode nvarchar(40)
    Declare @peli_PRCompanyId int

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, peli_PersonId,peli_PRTitleCode,peli_PRCompanyId
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@peli_PRTitleCode,@peli_PRCompanyId
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
            SET @Msg = 'Changes Failed.  History ' + convert(varchar,@peli_PersonLinkId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = convert(varchar(50), @peli_PRTitleCode)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = comp_name FROM Company
                WHERE comp_companyid = @peli_PRCompanyId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @peli_PRCompanyId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, 
            'peli_PRTitleCode,comp_name', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@peli_PRTitleCode,@peli_PRCompanyId
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

        Declare @ins_prba_StartDate nvarchar(50), @del_prba_StartDate nvarchar(50)
        Declare @ins_prba_EndDate nvarchar(50), @del_prba_EndDate nvarchar(50)
        Declare @ins_prba_Company nvarchar(50), @del_prba_Company nvarchar(50)
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

        DROP TABLE #TextTable
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prba_PersonId int, prba_Company nvarchar(50), prba_Title nvarchar(50))
    INSERT INTO @ProcessTable
        SELECT 'Insert',prba_PersonId,prba_Company,prba_Title
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prba_PersonId,prba_Company,prba_Title
        FROM Deleted


    Declare @prba_Company nvarchar(50)
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
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = convert(varchar(50), @prba_Title)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

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
            @ins_prpe_PublishUntilDate = i.prpe_PublishUntilDate, @del_prpe_PublishUntilDate = d.prpe_PublishUntilDate,
            @ins_prpe_PublishCreditSheet = i.prpe_PublishCreditSheet, @del_prpe_PublishCreditSheet = d.prpe_PublishCreditSheet
        FROM Inserted i
        INNER JOIN deleted d ON i.prpe_PersonEventId = d.prpe_PersonEventId

        -- prpe_PersonEventTypeId
        IF  (  Update(prpe_PersonEventTypeId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prpt_Name FROM PRPersonEventType
                WHERE prpt_PersonEventTypeId = @ins_prpe_PersonEventTypeId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_prpe_PersonEventTypeId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prpt_Name FROM PRPersonEventType
                WHERE prpt_PersonEventTypeId = @del_prpe_PersonEventTypeId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_prpe_PersonEventTypeId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_PersonEventTypeId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_Date
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prpe_Date, @ins_prpe_Date) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prpe_Date IS NOT NULL AND convert(varchar,@del_prpe_Date,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(3000), @del_prpe_Date)
            IF (@ins_prpe_Date IS NOT NULL AND convert(varchar,@ins_prpe_Date,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_prpe_Date)
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
        -- prpe_PublishUntilDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prpe_PublishUntilDate, @ins_prpe_PublishUntilDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prpe_PublishUntilDate IS NOT NULL AND convert(varchar,@del_prpe_PublishUntilDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(3000), @del_prpe_PublishUntilDate)
            IF (@ins_prpe_PublishUntilDate IS NOT NULL AND convert(varchar,@ins_prpe_PublishUntilDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_prpe_PublishUntilDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_PublishUntilDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prpe_PublishCreditSheet
        IF  (  Update(prpe_PublishCreditSheet))
        BEGIN
            SET @OldValue =  @del_prpe_PublishCreditSheet
            SET @NewValue =  @ins_prpe_PublishCreditSheet
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_PublishCreditSheet', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END


        -- prpe_PublishedAnalysis
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prpe_PublishedAnalysis, d.prpe_PublishedAnalysis
            FROM Inserted i
            INNER JOIN deleted d ON i.prpe_PersonEventId = d.prpe_PersonEventId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_PublishedAnalysis', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- prpe_InternalAnalysis
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prpe_InternalAnalysis, d.prpe_InternalAnalysis
            FROM Inserted i
            INNER JOIN deleted d ON i.prpe_PersonEventId = d.prpe_PersonEventId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Person Event', @Action, 'prpe_InternalAnalysis', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable
        DROP TABLE #TextTable
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
        PRPersonEvent.prpe_PublishCreditSheet=i.prpe_PublishCreditSheet
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

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
            SELECT @NewValueTemp = pers_LastName FROM Person
                WHERE pers_personid = @ins_prpr_RightPersonId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_prpr_RightPersonId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_LastName FROM Person
                WHERE pers_personid = @del_prpr_RightPersonId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_prpr_RightPersonId))

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

        DROP TABLE #TextTable
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
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
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
        SELECT @NewValueTemp = pers_LastName FROM Person
                WHERE pers_personid = @prpr_RightPersonId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prpr_RightPersonId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = convert(varchar(50), @prpr_Description)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

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
/* ************************************************************
 * Name:   dbo.trg_PRBusinessEvent_ioupd
 * 
 * Table:  PRBusinessEvent
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Auto-generated INSTEAD OF UPDATE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRBusinessEvent_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRBusinessEvent_ioupd]
GO

CREATE TRIGGER dbo.trg_PRBusinessEvent_ioupd
ON PRBusinessEvent
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
    Declare @prbe_BusinessEventId int
    Declare @UserId int
    Declare @BusinessEventId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.prbe_BusinessEventId, @UserId = i.prbe_UpdatedBy, @prbe_BusinessEventId = i.prbe_BusinessEventId
        FROM Inserted i
        INNER JOIN deleted d ON i.prbe_BusinessEventId = d.prbe_BusinessEventId
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_BusinessEventId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (prbe_EffectiveDate) OR
        Update (prbe_CreditSheetPublish) OR
        Update (prbe_PublishUntilDate) OR
        Update (prbe_AnticipatedCompletionDate) OR
        Update (prbe_DisasterImpact) OR
        Update (prbe_AttorneyName) OR
        Update (prbe_AttorneyPhone) OR
        Update (prbe_CaseNumber) OR
        Update (prbe_Amount) OR
        Update (prbe_AssetAmount) OR
        Update (prbe_LiabilityAmount) OR
        Update (prbe_IndividualBuyerId) OR
        Update (prbe_IndividualSellerId) OR
        Update (prbe_RelatedCompany1Id) OR
        Update (prbe_RelatedCompany2Id) OR
        Update (prbe_AgreementCategory) OR
        Update (prbe_AssigneeTrusteeName) OR
        Update (prbe_AssigneeTrusteeAddress) OR
        Update (prbe_AssigneeTrusteePhone) OR
        Update (prbe_SpecifiedCSNumeral) OR
        Update (prbe_USBankruptcyVoluntary) OR
        Update (prbe_USBankruptcyEntity) OR
        Update (prbe_USBankruptcyCourt) OR
        Update (prbe_StateId) OR
        Update (prbe_Names) OR
        Update (prbe_PercentSold) OR
        Update (prbe_CourtDistrict) OR
        Update (prbe_NumberSellers) OR
        Update (prbe_NonPromptStart) OR
        Update (prbe_NonPromptEnd) OR
        Update (prbe_BusinessOperateUntil) OR
        Update (prbe_IndividualOperateUntil) OR
        Update (prbe_DisplayedEffectiveDate) OR
        Update (prbe_DisplayedEffectiveDateStyle) OR
        Update (prbe_DetailedType) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Business Event ' + convert(varchar,@prbe_BusinessEventId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId int, insText Text, delText Text)

        Declare @ins_prbe_EffectiveDate datetime, @del_prbe_EffectiveDate datetime
        Declare @ins_prbe_CreditSheetPublish nchar(1), @del_prbe_CreditSheetPublish nchar(1)
        Declare @ins_prbe_PublishUntilDate datetime, @del_prbe_PublishUntilDate datetime
        Declare @ins_prbe_AnticipatedCompletionDate nvarchar(15), @del_prbe_AnticipatedCompletionDate nvarchar(15)
        Declare @ins_prbe_DisasterImpact nvarchar(40), @del_prbe_DisasterImpact nvarchar(40)
        Declare @ins_prbe_AttorneyName nvarchar(30), @del_prbe_AttorneyName nvarchar(30)
        Declare @ins_prbe_AttorneyPhone nvarchar(20), @del_prbe_AttorneyPhone nvarchar(20)
        Declare @ins_prbe_CaseNumber nvarchar(15), @del_prbe_CaseNumber nvarchar(15)
        Declare @ins_prbe_Amount numeric, @del_prbe_Amount numeric
        Declare @ins_prbe_AssetAmount numeric, @del_prbe_AssetAmount numeric
        Declare @ins_prbe_LiabilityAmount numeric, @del_prbe_LiabilityAmount numeric
        Declare @ins_prbe_IndividualBuyerId int, @del_prbe_IndividualBuyerId int
        Declare @ins_prbe_IndividualSellerId int, @del_prbe_IndividualSellerId int
        Declare @ins_prbe_RelatedCompany1Id int, @del_prbe_RelatedCompany1Id int
        Declare @ins_prbe_RelatedCompany2Id int, @del_prbe_RelatedCompany2Id int
        Declare @ins_prbe_AgreementCategory nvarchar(40), @del_prbe_AgreementCategory nvarchar(40)
        Declare @ins_prbe_AssigneeTrusteeName nvarchar(30), @del_prbe_AssigneeTrusteeName nvarchar(30)
        Declare @ins_prbe_AssigneeTrusteeAddress nvarchar(30), @del_prbe_AssigneeTrusteeAddress nvarchar(30)
        Declare @ins_prbe_AssigneeTrusteePhone nvarchar(30), @del_prbe_AssigneeTrusteePhone nvarchar(30)
        Declare @ins_prbe_SpecifiedCSNumeral nvarchar(40), @del_prbe_SpecifiedCSNumeral nvarchar(40)
        Declare @ins_prbe_USBankruptcyVoluntary nchar(1), @del_prbe_USBankruptcyVoluntary nchar(1)
        Declare @ins_prbe_USBankruptcyEntity nvarchar(40), @del_prbe_USBankruptcyEntity nvarchar(40)
        Declare @ins_prbe_USBankruptcyCourt nvarchar(40), @del_prbe_USBankruptcyCourt nvarchar(40)
        Declare @ins_prbe_StateId int, @del_prbe_StateId int
        Declare @ins_prbe_Names nvarchar(100), @del_prbe_Names nvarchar(100)
        Declare @ins_prbe_PercentSold numeric, @del_prbe_PercentSold numeric
        Declare @ins_prbe_CourtDistrict nvarchar(50), @del_prbe_CourtDistrict nvarchar(50)
        Declare @ins_prbe_NumberSellers int, @del_prbe_NumberSellers int
        Declare @ins_prbe_NonPromptStart nvarchar(20), @del_prbe_NonPromptStart nvarchar(20)
        Declare @ins_prbe_NonPromptEnd nvarchar(20), @del_prbe_NonPromptEnd nvarchar(20)
        Declare @ins_prbe_BusinessOperateUntil datetime, @del_prbe_BusinessOperateUntil datetime
        Declare @ins_prbe_IndividualOperateUntil datetime, @del_prbe_IndividualOperateUntil datetime
        Declare @ins_prbe_DisplayedEffectiveDate nvarchar(15), @del_prbe_DisplayedEffectiveDate nvarchar(15)
        Declare @ins_prbe_DisplayedEffectiveDateStyle nvarchar(40), @del_prbe_DisplayedEffectiveDateStyle nvarchar(40)
        Declare @ins_prbe_DetailedType nvarchar(40), @del_prbe_DetailedType nvarchar(40)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_prbe_EffectiveDate = i.prbe_EffectiveDate, @del_prbe_EffectiveDate = d.prbe_EffectiveDate,
            @ins_prbe_CreditSheetPublish = i.prbe_CreditSheetPublish, @del_prbe_CreditSheetPublish = d.prbe_CreditSheetPublish,
            @ins_prbe_PublishUntilDate = i.prbe_PublishUntilDate, @del_prbe_PublishUntilDate = d.prbe_PublishUntilDate,
            @ins_prbe_AnticipatedCompletionDate = i.prbe_AnticipatedCompletionDate, @del_prbe_AnticipatedCompletionDate = d.prbe_AnticipatedCompletionDate,
            @ins_prbe_DisasterImpact = i.prbe_DisasterImpact, @del_prbe_DisasterImpact = d.prbe_DisasterImpact,
            @ins_prbe_AttorneyName = i.prbe_AttorneyName, @del_prbe_AttorneyName = d.prbe_AttorneyName,
            @ins_prbe_AttorneyPhone = i.prbe_AttorneyPhone, @del_prbe_AttorneyPhone = d.prbe_AttorneyPhone,
            @ins_prbe_CaseNumber = i.prbe_CaseNumber, @del_prbe_CaseNumber = d.prbe_CaseNumber,
            @ins_prbe_Amount = i.prbe_Amount, @del_prbe_Amount = d.prbe_Amount,
            @ins_prbe_AssetAmount = i.prbe_AssetAmount, @del_prbe_AssetAmount = d.prbe_AssetAmount,
            @ins_prbe_LiabilityAmount = i.prbe_LiabilityAmount, @del_prbe_LiabilityAmount = d.prbe_LiabilityAmount,
            @ins_prbe_IndividualBuyerId = i.prbe_IndividualBuyerId, @del_prbe_IndividualBuyerId = d.prbe_IndividualBuyerId,
            @ins_prbe_IndividualSellerId = i.prbe_IndividualSellerId, @del_prbe_IndividualSellerId = d.prbe_IndividualSellerId,
            @ins_prbe_RelatedCompany1Id = i.prbe_RelatedCompany1Id, @del_prbe_RelatedCompany1Id = d.prbe_RelatedCompany1Id,
            @ins_prbe_RelatedCompany2Id = i.prbe_RelatedCompany2Id, @del_prbe_RelatedCompany2Id = d.prbe_RelatedCompany2Id,
            @ins_prbe_AgreementCategory = i.prbe_AgreementCategory, @del_prbe_AgreementCategory = d.prbe_AgreementCategory,
            @ins_prbe_AssigneeTrusteeName = i.prbe_AssigneeTrusteeName, @del_prbe_AssigneeTrusteeName = d.prbe_AssigneeTrusteeName,
            @ins_prbe_AssigneeTrusteeAddress = i.prbe_AssigneeTrusteeAddress, @del_prbe_AssigneeTrusteeAddress = d.prbe_AssigneeTrusteeAddress,
            @ins_prbe_AssigneeTrusteePhone = i.prbe_AssigneeTrusteePhone, @del_prbe_AssigneeTrusteePhone = d.prbe_AssigneeTrusteePhone,
            @ins_prbe_SpecifiedCSNumeral = i.prbe_SpecifiedCSNumeral, @del_prbe_SpecifiedCSNumeral = d.prbe_SpecifiedCSNumeral,
            @ins_prbe_USBankruptcyVoluntary = i.prbe_USBankruptcyVoluntary, @del_prbe_USBankruptcyVoluntary = d.prbe_USBankruptcyVoluntary,
            @ins_prbe_USBankruptcyEntity = i.prbe_USBankruptcyEntity, @del_prbe_USBankruptcyEntity = d.prbe_USBankruptcyEntity,
            @ins_prbe_USBankruptcyCourt = i.prbe_USBankruptcyCourt, @del_prbe_USBankruptcyCourt = d.prbe_USBankruptcyCourt,
            @ins_prbe_StateId = i.prbe_StateId, @del_prbe_StateId = d.prbe_StateId,
            @ins_prbe_Names = i.prbe_Names, @del_prbe_Names = d.prbe_Names,
            @ins_prbe_PercentSold = i.prbe_PercentSold, @del_prbe_PercentSold = d.prbe_PercentSold,
            @ins_prbe_CourtDistrict = i.prbe_CourtDistrict, @del_prbe_CourtDistrict = d.prbe_CourtDistrict,
            @ins_prbe_NumberSellers = i.prbe_NumberSellers, @del_prbe_NumberSellers = d.prbe_NumberSellers,
            @ins_prbe_NonPromptStart = i.prbe_NonPromptStart, @del_prbe_NonPromptStart = d.prbe_NonPromptStart,
            @ins_prbe_NonPromptEnd = i.prbe_NonPromptEnd, @del_prbe_NonPromptEnd = d.prbe_NonPromptEnd,
            @ins_prbe_BusinessOperateUntil = i.prbe_BusinessOperateUntil, @del_prbe_BusinessOperateUntil = d.prbe_BusinessOperateUntil,
            @ins_prbe_IndividualOperateUntil = i.prbe_IndividualOperateUntil, @del_prbe_IndividualOperateUntil = d.prbe_IndividualOperateUntil,
            @ins_prbe_DisplayedEffectiveDate = i.prbe_DisplayedEffectiveDate, @del_prbe_DisplayedEffectiveDate = d.prbe_DisplayedEffectiveDate,
            @ins_prbe_DisplayedEffectiveDateStyle = i.prbe_DisplayedEffectiveDateStyle, @del_prbe_DisplayedEffectiveDateStyle = d.prbe_DisplayedEffectiveDateStyle,
            @ins_prbe_DetailedType = i.prbe_DetailedType, @del_prbe_DetailedType = d.prbe_DetailedType
        FROM Inserted i
        INNER JOIN deleted d ON i.prbe_BusinessEventId = d.prbe_BusinessEventId

        -- prbe_EffectiveDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prbe_EffectiveDate, @ins_prbe_EffectiveDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prbe_EffectiveDate IS NOT NULL AND convert(varchar,@del_prbe_EffectiveDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(3000), @del_prbe_EffectiveDate)
            IF (@ins_prbe_EffectiveDate IS NOT NULL AND convert(varchar,@ins_prbe_EffectiveDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_prbe_EffectiveDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_EffectiveDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_CreditSheetPublish
        IF  (  Update(prbe_CreditSheetPublish))
        BEGIN
            SET @OldValue =  @del_prbe_CreditSheetPublish
            SET @NewValue =  @ins_prbe_CreditSheetPublish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_CreditSheetPublish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_PublishUntilDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prbe_PublishUntilDate, @ins_prbe_PublishUntilDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prbe_PublishUntilDate IS NOT NULL AND convert(varchar,@del_prbe_PublishUntilDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(3000), @del_prbe_PublishUntilDate)
            IF (@ins_prbe_PublishUntilDate IS NOT NULL AND convert(varchar,@ins_prbe_PublishUntilDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_prbe_PublishUntilDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_PublishUntilDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_AnticipatedCompletionDate
        IF  (  Update(prbe_AnticipatedCompletionDate))
        BEGIN
            SET @OldValue =  @del_prbe_AnticipatedCompletionDate
            SET @NewValue =  @ins_prbe_AnticipatedCompletionDate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_AnticipatedCompletionDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_DisasterImpact
        IF  (  Update(prbe_DisasterImpact))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='prbe_DisasterImpact' AND capt_code = @ins_prbe_DisasterImpact
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prbe_DisasterImpact)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='prbe_DisasterImpact' AND capt_code = @del_prbe_DisasterImpact
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prbe_DisasterImpact)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_DisasterImpact', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_AttorneyName
        IF  (  Update(prbe_AttorneyName))
        BEGIN
            SET @OldValue =  @del_prbe_AttorneyName
            SET @NewValue =  @ins_prbe_AttorneyName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_AttorneyName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_AttorneyPhone
        IF  (  Update(prbe_AttorneyPhone))
        BEGIN
            SET @OldValue =  @del_prbe_AttorneyPhone
            SET @NewValue =  @ins_prbe_AttorneyPhone
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_AttorneyPhone', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_CaseNumber
        IF  (  Update(prbe_CaseNumber))
        BEGIN
            SET @OldValue =  @del_prbe_CaseNumber
            SET @NewValue =  @ins_prbe_CaseNumber
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_CaseNumber', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_Amount
        IF  (  Update(prbe_Amount))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prbe_Amount)
            SET @NewValue =  convert(varchar(3000), @ins_prbe_Amount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_Amount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_AssetAmount
        IF  (  Update(prbe_AssetAmount))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prbe_AssetAmount)
            SET @NewValue =  convert(varchar(3000), @ins_prbe_AssetAmount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_AssetAmount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_LiabilityAmount
        IF  (  Update(prbe_LiabilityAmount))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prbe_LiabilityAmount)
            SET @NewValue =  convert(varchar(3000), @ins_prbe_LiabilityAmount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_LiabilityAmount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_IndividualBuyerId
        IF  (  Update(prbe_IndividualBuyerId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_firstname + ' ' + pers_lastname FROM person
                WHERE pers_PersonId = @ins_prbe_IndividualBuyerId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_prbe_IndividualBuyerId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_firstname + ' ' + pers_lastname FROM person
                WHERE pers_PersonId = @del_prbe_IndividualBuyerId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_prbe_IndividualBuyerId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_IndividualBuyerId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_IndividualSellerId
        IF  (  Update(prbe_IndividualSellerId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_firstname + ' ' + pers_lastname FROM person
                WHERE pers_PersonId = @ins_prbe_IndividualSellerId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_prbe_IndividualSellerId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_firstname + ' ' + pers_lastname FROM person
                WHERE pers_PersonId = @del_prbe_IndividualSellerId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_prbe_IndividualSellerId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_IndividualSellerId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_RelatedCompany1Id
        IF  (  Update(prbe_RelatedCompany1Id))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM company
                WHERE comp_companyid = @ins_prbe_RelatedCompany1Id
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_prbe_RelatedCompany1Id))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM company
                WHERE comp_companyid = @del_prbe_RelatedCompany1Id
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_prbe_RelatedCompany1Id))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_RelatedCompany1Id', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_RelatedCompany2Id
        IF  (  Update(prbe_RelatedCompany2Id))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM company
                WHERE comp_companyid = @ins_prbe_RelatedCompany2Id
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_prbe_RelatedCompany2Id))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM company
                WHERE comp_companyid = @del_prbe_RelatedCompany2Id
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_prbe_RelatedCompany2Id))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_RelatedCompany2Id', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_AgreementCategory
        IF  (  Update(prbe_AgreementCategory))
        BEGIN
            SET @OldValue =  @del_prbe_AgreementCategory
            SET @NewValue =  @ins_prbe_AgreementCategory
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_AgreementCategory', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_AssigneeTrusteeName
        IF  (  Update(prbe_AssigneeTrusteeName))
        BEGIN
            SET @OldValue =  @del_prbe_AssigneeTrusteeName
            SET @NewValue =  @ins_prbe_AssigneeTrusteeName
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_AssigneeTrusteeName', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_AssigneeTrusteeAddress
        IF  (  Update(prbe_AssigneeTrusteeAddress))
        BEGIN
            SET @OldValue =  @del_prbe_AssigneeTrusteeAddress
            SET @NewValue =  @ins_prbe_AssigneeTrusteeAddress
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_AssigneeTrusteeAddress', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_AssigneeTrusteePhone
        IF  (  Update(prbe_AssigneeTrusteePhone))
        BEGIN
            SET @OldValue =  @del_prbe_AssigneeTrusteePhone
            SET @NewValue =  @ins_prbe_AssigneeTrusteePhone
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_AssigneeTrusteePhone', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_SpecifiedCSNumeral
        IF  (  Update(prbe_SpecifiedCSNumeral))
        BEGIN
            SET @OldValue =  @del_prbe_SpecifiedCSNumeral
            SET @NewValue =  @ins_prbe_SpecifiedCSNumeral
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_SpecifiedCSNumeral', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_USBankruptcyVoluntary
        IF  (  Update(prbe_USBankruptcyVoluntary))
        BEGIN
            SET @OldValue =  @del_prbe_USBankruptcyVoluntary
            SET @NewValue =  @ins_prbe_USBankruptcyVoluntary
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_USBankruptcyVoluntary', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_USBankruptcyEntity
        IF  (  Update(prbe_USBankruptcyEntity))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='prbe_USBankruptcyEntity' AND capt_code = @ins_prbe_USBankruptcyEntity
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prbe_USBankruptcyEntity)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='prbe_USBankruptcyEntity' AND capt_code = @del_prbe_USBankruptcyEntity
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prbe_USBankruptcyEntity)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_USBankruptcyEntity', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_USBankruptcyCourt
        IF  (  Update(prbe_USBankruptcyCourt))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='prbe_USBankruptcyCourt' AND capt_code = @ins_prbe_USBankruptcyCourt
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prbe_USBankruptcyCourt)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions
                WHERE capt_family='prbe_USBankruptcyCourt' AND capt_code = @del_prbe_USBankruptcyCourt
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prbe_USBankruptcyCourt)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_USBankruptcyCourt', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_StateId
        IF  (  Update(prbe_StateId))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prbe_StateId)
            SET @NewValue =  convert(varchar(3000), @ins_prbe_StateId)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_StateId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_Names
        IF  (  Update(prbe_Names))
        BEGIN
            SET @OldValue =  @del_prbe_Names
            SET @NewValue =  @ins_prbe_Names
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_Names', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_PercentSold
        IF  (  Update(prbe_PercentSold))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prbe_PercentSold)
            SET @NewValue =  convert(varchar(3000), @ins_prbe_PercentSold)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_PercentSold', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_CourtDistrict
        IF  (  Update(prbe_CourtDistrict))
        BEGIN
            SET @OldValue =  @del_prbe_CourtDistrict
            SET @NewValue =  @ins_prbe_CourtDistrict
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_CourtDistrict', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_NumberSellers
        IF  (  Update(prbe_NumberSellers))
        BEGIN
            SET @OldValue =  convert(varchar(3000), @del_prbe_NumberSellers)
            SET @NewValue =  convert(varchar(3000), @ins_prbe_NumberSellers)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_NumberSellers', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_NonPromptStart
        IF  (  Update(prbe_NonPromptStart))
        BEGIN
            SET @OldValue =  @del_prbe_NonPromptStart
            SET @NewValue =  @ins_prbe_NonPromptStart
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_NonPromptStart', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_NonPromptEnd
        IF  (  Update(prbe_NonPromptEnd))
        BEGIN
            SET @OldValue =  @del_prbe_NonPromptEnd
            SET @NewValue =  @ins_prbe_NonPromptEnd
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_NonPromptEnd', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_BusinessOperateUntil
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prbe_BusinessOperateUntil, @ins_prbe_BusinessOperateUntil) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prbe_BusinessOperateUntil IS NOT NULL AND convert(varchar,@del_prbe_BusinessOperateUntil,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(3000), @del_prbe_BusinessOperateUntil)
            IF (@ins_prbe_BusinessOperateUntil IS NOT NULL AND convert(varchar,@ins_prbe_BusinessOperateUntil,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_prbe_BusinessOperateUntil)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_BusinessOperateUntil', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_IndividualOperateUntil
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prbe_IndividualOperateUntil, @ins_prbe_IndividualOperateUntil) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prbe_IndividualOperateUntil IS NOT NULL AND convert(varchar,@del_prbe_IndividualOperateUntil,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(3000), @del_prbe_IndividualOperateUntil)
            IF (@ins_prbe_IndividualOperateUntil IS NOT NULL AND convert(varchar,@ins_prbe_IndividualOperateUntil,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(3000), @ins_prbe_IndividualOperateUntil)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_IndividualOperateUntil', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_DisplayedEffectiveDate
        IF  (  Update(prbe_DisplayedEffectiveDate))
        BEGIN
            SET @OldValue =  @del_prbe_DisplayedEffectiveDate
            SET @NewValue =  @ins_prbe_DisplayedEffectiveDate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_DisplayedEffectiveDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_DisplayedEffectiveDateStyle
        IF  (  Update(prbe_DisplayedEffectiveDateStyle))
        BEGIN
            SET @OldValue =  @del_prbe_DisplayedEffectiveDateStyle
            SET @NewValue =  @ins_prbe_DisplayedEffectiveDateStyle
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_DisplayedEffectiveDateStyle', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_DetailedType
        IF  (  Update(prbe_DetailedType))
        BEGIN
            SET @OldValue =  @del_prbe_DetailedType
            SET @NewValue =  @ins_prbe_DetailedType
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_DetailedType', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END


        -- prbe_CreditSheetNote
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prbe_CreditSheetNote, d.prbe_CreditSheetNote
            FROM Inserted i
            INNER JOIN deleted d ON i.prbe_BusinessEventId = d.prbe_BusinessEventId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_CreditSheetNote', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- prbe_PublishedAnalysis
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prbe_PublishedAnalysis, d.prbe_PublishedAnalysis
            FROM Inserted i
            INNER JOIN deleted d ON i.prbe_BusinessEventId = d.prbe_BusinessEventId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_PublishedAnalysis', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- prbe_InternalAnalysis
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prbe_InternalAnalysis, d.prbe_InternalAnalysis
            FROM Inserted i
            INNER JOIN deleted d ON i.prbe_BusinessEventId = d.prbe_BusinessEventId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_InternalAnalysis', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable

        -- prbe_OtherDescription
        INSERT INTO #TextTable Select @prtx_TransactionId,
            i.prbe_OtherDescription, d.prbe_OtherDescription
            FROM Inserted i
            INNER JOIN deleted d ON i.prbe_BusinessEventId = d.prbe_BusinessEventId
        IF (@Err = 0 AND exists(select 1 from #TextTable where insText NOT Like delText))
        BEGIN
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_OtherDescription', 'Text Change', 'Text Change', @UserId, @TransactionDetailTypeId
            SET @Err = @@Error
        End
        delete from #TextTable
        DROP TABLE #TextTable
    END
    IF (@Err = 0) 
    BEGIN
        UPDATE PRBusinessEvent SET 
        PRBusinessEvent.prbe_BusinessEventId=i.prbe_BusinessEventId, 
        PRBusinessEvent.prbe_Deleted=i.prbe_Deleted, 
        PRBusinessEvent.prbe_WorkflowId=i.prbe_WorkflowId, 
        PRBusinessEvent.prbe_Secterr=i.prbe_Secterr, 
        PRBusinessEvent.prbe_CreatedBy=i.prbe_CreatedBy, 
        PRBusinessEvent.prbe_CreatedDate=dbo.ufn_GetAccpacDate(i.prbe_CreatedDate), 
        PRBusinessEvent.prbe_UpdatedBy=i.prbe_UpdatedBy, 
        PRBusinessEvent.prbe_UpdatedDate=dbo.ufn_GetAccpacDate(i.prbe_UpdatedDate), 
        PRBusinessEvent.prbe_TimeStamp=dbo.ufn_GetAccpacDate(i.prbe_TimeStamp), 
        PRBusinessEvent.prbe_CompanyId=i.prbe_CompanyId, 
        PRBusinessEvent.prbe_BusinessEventTypeId=i.prbe_BusinessEventTypeId, 
        PRBusinessEvent.prbe_EffectiveDate=dbo.ufn_GetAccpacDate(i.prbe_EffectiveDate), 
        PRBusinessEvent.prbe_CreditSheetPublish=i.prbe_CreditSheetPublish, 
        PRBusinessEvent.prbe_CreditSheetNote=i.prbe_CreditSheetNote, 
        PRBusinessEvent.prbe_PublishedAnalysis=i.prbe_PublishedAnalysis, 
        PRBusinessEvent.prbe_InternalAnalysis=i.prbe_InternalAnalysis, 
        PRBusinessEvent.prbe_PublishUntilDate=dbo.ufn_GetAccpacDate(i.prbe_PublishUntilDate), 
        PRBusinessEvent.prbe_AnticipatedCompletionDate=i.prbe_AnticipatedCompletionDate, 
        PRBusinessEvent.prbe_DisasterImpact=i.prbe_DisasterImpact, 
        PRBusinessEvent.prbe_AttorneyName=i.prbe_AttorneyName, 
        PRBusinessEvent.prbe_AttorneyPhone=i.prbe_AttorneyPhone, 
        PRBusinessEvent.prbe_CaseNumber=i.prbe_CaseNumber, 
        PRBusinessEvent.prbe_Amount=i.prbe_Amount, 
        PRBusinessEvent.prbe_AssetAmount=i.prbe_AssetAmount, 
        PRBusinessEvent.prbe_LiabilityAmount=i.prbe_LiabilityAmount, 
        PRBusinessEvent.prbe_IndividualBuyerId=i.prbe_IndividualBuyerId, 
        PRBusinessEvent.prbe_IndividualSellerId=i.prbe_IndividualSellerId, 
        PRBusinessEvent.prbe_RelatedCompany1Id=i.prbe_RelatedCompany1Id, 
        PRBusinessEvent.prbe_RelatedCompany2Id=i.prbe_RelatedCompany2Id, 
        PRBusinessEvent.prbe_AgreementCategory=i.prbe_AgreementCategory, 
        PRBusinessEvent.prbe_AssigneeTrusteeName=i.prbe_AssigneeTrusteeName, 
        PRBusinessEvent.prbe_AssigneeTrusteeAddress=i.prbe_AssigneeTrusteeAddress, 
        PRBusinessEvent.prbe_AssigneeTrusteePhone=i.prbe_AssigneeTrusteePhone, 
        PRBusinessEvent.prbe_SpecifiedCSNumeral=i.prbe_SpecifiedCSNumeral, 
        PRBusinessEvent.prbe_USBankruptcyVoluntary=i.prbe_USBankruptcyVoluntary, 
        PRBusinessEvent.prbe_USBankruptcyEntity=i.prbe_USBankruptcyEntity, 
        PRBusinessEvent.prbe_USBankruptcyCourt=i.prbe_USBankruptcyCourt, 
        PRBusinessEvent.prbe_StateId=i.prbe_StateId, 
        PRBusinessEvent.prbe_Names=i.prbe_Names, 
        PRBusinessEvent.prbe_PercentSold=i.prbe_PercentSold, 
        PRBusinessEvent.prbe_CourtDistrict=i.prbe_CourtDistrict, 
        PRBusinessEvent.prbe_NumberSellers=i.prbe_NumberSellers, 
        PRBusinessEvent.prbe_NonPromptStart=i.prbe_NonPromptStart, 
        PRBusinessEvent.prbe_NonPromptEnd=i.prbe_NonPromptEnd, 
        PRBusinessEvent.prbe_BusinessOperateUntil=dbo.ufn_GetAccpacDate(i.prbe_BusinessOperateUntil), 
        PRBusinessEvent.prbe_IndividualOperateUntil=dbo.ufn_GetAccpacDate(i.prbe_IndividualOperateUntil), 
        PRBusinessEvent.prbe_DisplayedEffectiveDate=i.prbe_DisplayedEffectiveDate, 
        PRBusinessEvent.prbe_DisplayedEffectiveDateStyle=i.prbe_DisplayedEffectiveDateStyle, 
        PRBusinessEvent.prbe_DetailedType=i.prbe_DetailedType, 
        PRBusinessEvent.prbe_OtherDescription=i.prbe_OtherDescription
        FROM inserted i 
          INNER JOIN PRBusinessEvent ON i.prbe_BusinessEventId=PRBusinessEvent.prbe_BusinessEventId
    END
END
GO
