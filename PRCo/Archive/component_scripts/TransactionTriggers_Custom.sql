/* ************************************************************
 * Name:   dbo.trg_Phone_ioupd
 * 
 * Table:  Phone
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Custom INSTEAD OF UPDATE trigger;
 *          This is primarily based upon our Auto-generated 
 *          structure, but special handling must be done to 
 *          determine if a company or a person record is being
 *          updated. 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Phone_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Phone_ioupd]
GO

CREATE TRIGGER dbo.trg_Phone_ioupd
ON Phone
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
    Declare @Phon_PhoneId int
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

    SELECT @TrxKeyId = 
        case 
            when i.phon_PersonId IS NOT NULL Then i.phon_PersonId
            else i.phon_CompanyId
        end,
        @UserId = i.Phon_UpdatedBy, @Phon_PhoneId = i.Phon_PhoneId
        FROM Inserted i
        INNER JOIN deleted d ON i.Phon_PhoneId = d.Phon_PhoneId
    -- if there is nothing to update, just return
	IF (@TrxKeyId IS NULL)
		RETURN

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE (prtx_CompanyId = @TrxKeyId or prtx_PersonId = @TrxKeyId)
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (Phon_Type) OR
        Update (Phon_CountryCode) OR
        Update (Phon_AreaCode) OR
        Update (Phon_Number) OR
        Update (phon_PRDescription) OR
        Update (phon_PRExtension) OR
        Update (phon_PRInternational) OR
        Update (phon_PRCityCode) OR
        Update (phon_PRPublish) OR
        Update (phon_PRDisconnected) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Phone ' + convert(varchar,@Phon_PhoneId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId smallint, insText Text, delText Text)

        Declare @ins_Phon_Type nvarchar(40), @del_Phon_Type nvarchar(40)
        Declare @ins_Phon_CountryCode nchar(5), @del_Phon_CountryCode nchar(5)
        Declare @ins_Phon_AreaCode nchar(20), @del_Phon_AreaCode nchar(20)
        Declare @ins_Phon_Number nchar(20), @del_Phon_Number nchar(20)
        Declare @ins_phon_PRDescription nvarchar(34), @del_phon_PRDescription nvarchar(34)
        Declare @ins_phon_PRExtension nvarchar(5), @del_phon_PRExtension nvarchar(5)
        Declare @ins_phon_PRInternational nchar(1), @del_phon_PRInternational nchar(1)
        Declare @ins_phon_PRCityCode nvarchar(5), @del_phon_PRCityCode nvarchar(5)
        Declare @ins_phon_PRPublish nchar(1), @del_phon_PRPublish nchar(1)
        Declare @ins_phon_PRDisconnected nchar(1), @del_phon_PRDisconnected nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_Phon_Type = i.Phon_Type, @del_Phon_Type = d.Phon_Type,
            @ins_Phon_CountryCode = i.Phon_CountryCode, @del_Phon_CountryCode = d.Phon_CountryCode,
            @ins_Phon_AreaCode = i.Phon_AreaCode, @del_Phon_AreaCode = d.Phon_AreaCode,
            @ins_Phon_Number = i.Phon_Number, @del_Phon_Number = d.Phon_Number,
            @ins_phon_PRDescription = i.phon_PRDescription, @del_phon_PRDescription = d.phon_PRDescription,
            @ins_phon_PRExtension = i.phon_PRExtension, @del_phon_PRExtension = d.phon_PRExtension,
            @ins_phon_PRInternational = i.phon_PRInternational, @del_phon_PRInternational = d.phon_PRInternational,
            @ins_phon_PRCityCode = i.phon_PRCityCode, @del_phon_PRCityCode = d.phon_PRCityCode,
            @ins_phon_PRPublish = i.phon_PRPublish, @del_phon_PRPublish = d.phon_PRPublish,
            @ins_phon_PRDisconnected = i.phon_PRDisconnected, @del_phon_PRDisconnected = d.phon_PRDisconnected
        FROM Inserted i
        INNER JOIN deleted d ON i.Phon_PhoneId = d.Phon_PhoneId

        -- Phon_Type
        IF  (  Update(Phon_Type))
        BEGIN
            SET @OldValue = @del_Phon_Type
            SET @NewValue = @ins_Phon_Type
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'Phon_Type', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Phon_CountryCode
        IF  (  Update(Phon_CountryCode))
        BEGIN
            SET @OldValue = @del_Phon_CountryCode
            SET @NewValue = @ins_Phon_CountryCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'Phon_CountryCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Phon_AreaCode
        IF  (  Update(Phon_AreaCode))
        BEGIN
            SET @OldValue = @del_Phon_AreaCode
            SET @NewValue = @ins_Phon_AreaCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'Phon_AreaCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Phon_Number
        IF  (  Update(Phon_Number))
        BEGIN
            SET @OldValue = @del_Phon_Number
            SET @NewValue = @ins_Phon_Number
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'Phon_Number', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- phon_PRDescription
        IF  (  Update(phon_PRDescription))
        BEGIN
            SET @OldValue = @del_phon_PRDescription
            SET @NewValue = @ins_phon_PRDescription
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'phon_PRDescription', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- phon_PRExtension
        IF  (  Update(phon_PRExtension))
        BEGIN
            SET @OldValue = @del_phon_PRExtension
            SET @NewValue = @ins_phon_PRExtension
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'phon_PRExtension', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- phon_PRInternational
        IF  (  Update(phon_PRInternational))
        BEGIN
            SET @OldValue = @del_phon_PRInternational
            SET @NewValue = @ins_phon_PRInternational
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'phon_PRInternational', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- phon_PRCityCode
        IF  (  Update(phon_PRCityCode))
        BEGIN
            SET @OldValue = @del_phon_PRCityCode
            SET @NewValue = @ins_phon_PRCityCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'phon_PRCityCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- phon_PRPublish
        IF  (  Update(phon_PRPublish))
        BEGIN
            SET @OldValue = @del_phon_PRPublish
            SET @NewValue = @ins_phon_PRPublish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'phon_PRPublish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- phon_PRDisconnected
        IF  (  Update(phon_PRDisconnected))
        BEGIN
            SET @OldValue = @del_phon_PRDisconnected
            SET @NewValue = @ins_phon_PRDisconnected
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 'phon_PRDisconnected', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        DROP TABLE #TextTable
    END
    IF (@Err = 0) 
    BEGIN
        UPDATE Phone SET 
        Phone.Phon_PhoneId=i.Phon_PhoneId, 
        Phone.Phon_CompanyID=i.Phon_CompanyID, 
        Phone.Phon_PersonID=i.Phon_PersonID, 
        Phone.Phon_Type=i.Phon_Type, 
        Phone.Phon_CountryCode=i.Phon_CountryCode, 
        Phone.Phon_AreaCode=i.Phon_AreaCode, 
        Phone.Phon_Number=i.Phon_Number, 
        Phone.Phon_CreatedBy=i.Phon_CreatedBy, 
        Phone.Phon_CreatedDate=dbo.ufn_GetAccpacDate(i.Phon_CreatedDate), 
        Phone.Phon_UpdatedBy=i.Phon_UpdatedBy, 
        Phone.Phon_UpdatedDate=dbo.ufn_GetAccpacDate(i.Phon_UpdatedDate), 
        Phone.Phon_TimeStamp=dbo.ufn_GetAccpacDate(i.Phon_TimeStamp), 
        Phone.Phon_Deleted=i.Phon_Deleted, 
        Phone.Phon_SegmentID=i.Phon_SegmentID, 
        Phone.Phon_ChannelID=i.Phon_ChannelID, 
        Phone.phon_Default=i.phon_Default, 
        Phone.phon_PRDescription=i.phon_PRDescription, 
        Phone.phon_PRExtension=i.phon_PRExtension, 
        Phone.phon_PRInternational=i.phon_PRInternational, 
        Phone.phon_PRCityCode=i.phon_PRCityCode, 
        Phone.phon_PRPublish=i.phon_PRPublish, 
        Phone.phon_PRDisconnected=i.phon_PRDisconnected, 
        Phone.phon_PRSequence=i.phon_PRSequence,
        Phone.phon_PRReplicatedFromId=i.phon_PRReplicatedFromId
        FROM inserted i 
          INNER JOIN Phone ON i.Phon_PhoneId=Phone.Phon_PhoneId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_Phone_insdel
 * 
 * Table:  Phone
 * Action: FOR INSERT, DELETE
 * 
 * Description: Custom FOR INSERT, DELETE trigger
 *          This is primarily based upon our Auto-generated 
 *          structure, but special handling must be done to 
 *          determine if a company or a person record is being
 *          updated. 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Phone_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Phone_insdel]
GO

CREATE TRIGGER dbo.trg_Phone_insdel
ON Phone
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxCompanyKeyId int
    Declare @TrxPersonKeyId int
    Declare @Phon_PhoneId int
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
    Declare @ProcessTable TABLE(ProcessAction varchar(10), Phon_CompanyId int, Phon_PersonId int, Phon_Type nvarchar(40), Phon_AreaCode nchar(20), Phon_Number nchar(20))
    INSERT INTO @ProcessTable
        SELECT 'Insert',Phon_CompanyId,Phon_PersonId,Phon_Type,Phon_AreaCode,Phon_Number
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',Phon_CompanyId,Phon_PersonId,Phon_Type,Phon_AreaCode,Phon_Number
        FROM Deleted


    Declare @Phon_Type nvarchar(40)
    Declare @Phon_AreaCode nchar(20)
    Declare @Phon_Number nchar(20)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, Phon_CompanyId,Phon_PersonId,Phon_Type,Phon_AreaCode,Phon_Number
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxCompanyKeyId,@TrxPersonKeyId,@Phon_Type,@Phon_AreaCode,@Phon_Number
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
    WHERE (prtx_CompanyId = @TrxCompanyKeyId OR prtx_PersonId = @TrxPersonKeyId)
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Phone ' + convert(varchar,@Phon_PhoneId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = convert(varchar(50), @Phon_Type)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = convert(varchar(50), @Phon_AreaCode)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        SET @NewValueTemp = convert(varchar(50), @Phon_Number)
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, 
            'Phon_Type,Phon_AreaCode,Phon_Number', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxCompanyKeyId,@TrxPersonKeyId,@Phon_Type,@Phon_AreaCode,@Phon_Number
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO

/* ************************************************************
 * Name:   dbo.trg_Email_ioupd
 * 
 * Table:  Email
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Custom INSTEAD OF UPDATE trigger;
 *          This is primarily based upon our Auto-generated 
 *          structure, but special handling must be done to 
 *          determine if a company or a person record is being
 *          updated. 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Email_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Email_ioupd]
GO

CREATE TRIGGER dbo.trg_Email_ioupd
ON Email
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
    Declare @Emai_EmailId int
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

    SELECT @TrxKeyId = 
        case 
            when i.emai_PersonId IS NOT NULL Then i.emai_PersonId
            else i.emai_CompanyId
        end,
        @UserId = i.emai_UpdatedBy, @Emai_EmailId = i.Emai_EmailId
        FROM Inserted i
        INNER JOIN deleted d ON i.Emai_EmailId = d.Emai_EmailId

    -- if there is nothing to update, just return
	IF (@TrxKeyId IS NULL)
		RETURN

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE (prtx_CompanyId = @TrxKeyId or prtx_PersonId = @TrxKeyId)
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (Emai_Type) OR
        Update (Emai_EmailAddress) OR
        Update (Emai_PRWebAddress) OR
        Update (Emai_PRDescription) OR
        Update (Emai_PRDefault) OR
        Update (Emai_PRPublish) OR
        Update (Emai_PRSequence) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Email record ' + convert(varchar,@Emai_EmailId) + ' values can only be changed if a transaction is open.'
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId smallint, insText Text, delText Text)

        Declare @ins_Emai_Type nvarchar(40), @del_Emai_Type nvarchar(40)
        Declare @ins_Emai_EmailAddress nvarchar(255), @del_Emai_EmailAddress nvarchar(255)
        Declare @ins_Emai_PRWebAddress nvarchar(255), @del_Emai_PRWebAddress nvarchar(255)
        Declare @ins_Emai_PRDescription nvarchar(50), @del_Emai_PRDescription nvarchar(50)
        Declare @ins_Emai_PRDefault nchar(1), @del_Emai_PRDefault nchar(1)
        Declare @ins_Emai_PRPublish nchar(1), @del_Emai_PRPublish nchar(1)
        Declare @ins_Emai_PRSequence int, @del_Emai_PRSequence int
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_Emai_Type = i.Emai_Type, @del_Emai_Type = d.Emai_Type,
            @ins_Emai_EmailAddress = i.Emai_EmailAddress, @del_Emai_EmailAddress = d.Emai_EmailAddress,
            @ins_Emai_PRWebAddress = i.Emai_PRWebAddress, @del_Emai_PRWebAddress = d.Emai_PRWebAddress,
            @ins_Emai_PRDescription = i.Emai_PRDescription, @del_Emai_PRDescription = d.Emai_PRDescription,
            @ins_Emai_PRDefault = i.Emai_PRDefault, @del_Emai_PRDefault = d.Emai_PRDefault,
            @ins_Emai_PRPublish = i.Emai_PRPublish, @del_Emai_PRPublish = d.Emai_PRPublish,
            @ins_Emai_PRSequence = i.Emai_PRSequence, @del_Emai_PRSequence = d.Emai_PRSequence
        FROM Inserted i
        INNER JOIN deleted d ON i.Emai_EmailId = d.Emai_EmailId

        -- Emai_Type
        IF  (  Update(Emai_Type))
        BEGIN
            SET @OldValue = @del_Emai_Type
            SET @NewValue = @ins_Emai_Type
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, 'Emai_Type', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Emai_EmailAddress
        IF  (  Update(Emai_EmailAddress))
        BEGIN
            SET @OldValue = @del_Emai_EmailAddress
            SET @NewValue = @ins_Emai_EmailAddress
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, 'Emai_EmailAddress', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Emai_PRWebAddress
        IF  (  Update(Emai_PRWebAddress))
        BEGIN
            SET @OldValue = @del_Emai_PRWebAddress
            SET @NewValue = @ins_Emai_PRWebAddress
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, 'Emai_PRWebAddress', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Emai_PRDescription
        IF  (  Update(Emai_PRDescription))
        BEGIN
            SET @OldValue = @del_Emai_PRDescription
            SET @NewValue = @ins_Emai_PRDescription
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, 'Emai_PRDescription', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Emai_PRDefault
        IF  (  Update(Emai_PRDefault))
        BEGIN
            SET @OldValue = @del_Emai_PRDefault
            SET @NewValue = @ins_Emai_PRDefault
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, 'Emai_PRDefault', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Emai_PRPublish
        IF  (  Update(Emai_PRPublish))
        BEGIN
            SET @OldValue = @del_Emai_PRPublish
            SET @NewValue = @ins_Emai_PRPublish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, 'Emai_PRPublish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Emai_PRSequence
        IF  (  Update(Emai_PRSequence))
        BEGIN
            SET @OldValue = @del_Emai_PRSequence
            SET @NewValue = @ins_Emai_PRSequence
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, 'Emai_PRSequence', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        DROP TABLE #TextTable
    END
    IF (@Err = 0) 
    BEGIN
        UPDATE Email SET 
        Email.Emai_EmailId=i.Emai_EmailId, 
        Email.Emai_CompanyID=i.Emai_CompanyID, 
        Email.Emai_PersonID=i.Emai_PersonID, 
        Email.Emai_Type=i.Emai_Type, 
        Email.Emai_EmailAddress=i.Emai_EmailAddress, 
        Email.Emai_PRWebAddress=i.Emai_PRWebAddress, 
        Email.Emai_CreatedBy=i.Emai_CreatedBy, 
        Email.Emai_CreatedDate=dbo.ufn_GetAccpacDate(i.Emai_CreatedDate), 
        Email.Emai_UpdatedBy=i.Emai_UpdatedBy, 
        Email.Emai_UpdatedDate=dbo.ufn_GetAccpacDate(i.Emai_UpdatedDate), 
        Email.Emai_TimeStamp=dbo.ufn_GetAccpacDate(i.Emai_TimeStamp), 
        Email.Emai_Deleted=i.Emai_Deleted, 
        Email.Emai_SegmentID=i.Emai_SegmentID, 
        Email.Emai_ChannelID=i.Emai_ChannelID, 
        Email.Emai_PRDefault=i.Emai_PRDefault, 
        Email.Emai_PRDescription=i.Emai_PRDescription, 
        Email.Emai_PRPublish=i.Emai_PRPublish, 
        Email.Emai_PRSequence=i.Emai_PRSequence, 
        Email.Emai_PRReplicatedFromId=i.Emai_PRReplicatedFromId
        FROM inserted i 
          INNER JOIN Email ON i.Emai_EmailId=Email.Emai_EmailId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_Email_insdel
 * 
 * Table:  Email
 * Action: FOR INSERT, DELETE
 * 
 * Description: Custom FOR INSERT, DELETE trigger
 *          This is primarily based upon our Auto-generated 
 *          structure, but special handling must be done to 
 *          determine if a company or a person record is being
 *          updated. 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Email_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Email_insdel]
GO

CREATE TRIGGER dbo.trg_Email_insdel
ON Email
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxCompanyKeyId int
    Declare @TrxPersonKeyId int
    Declare @Emai_EmailId int
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
    Declare @ProcessTable TABLE(ProcessAction varchar(10), Emai_CompanyId int, Emai_PersonId int, Emai_EmailAddress nvarchar(255), Emai_PRWebAddress nchar(255))
    INSERT INTO @ProcessTable
        SELECT 'Insert',Emai_CompanyId,Emai_PersonId,Emai_EmailAddress,Emai_PRWebAddress
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',Emai_CompanyId,Emai_PersonId,Emai_EmailAddress,Emai_PRWebAddress
        FROM Deleted


    Declare @Emai_EmailAddress nvarchar(255)
    Declare @Emai_PRWebAddress nvarchar(255)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, Emai_CompanyId,Emai_PersonId,Emai_EmailAddress,Emai_PRWebAddress
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxCompanyKeyId,@TrxPersonKeyId,@Emai_EmailAddress,@Emai_PRWebAddress
    WHILE @@Fetch_Status=0
    BEGIN
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
		WHERE (prtx_CompanyId = @TrxCompanyKeyId OR prtx_PersonId = @TrxPersonKeyId)
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Email ' + convert(varchar,@Emai_EmailId) + ' values can only be changed if a transaction is open.'
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValue = COALESCE(@Emai_EmailAddress,@Emai_PRWebAddress,'')
		
		SET @Caption = case
			when @Emai_EmailAddress is not null then 'Emai_EmailAddress'
			else 'Emai_PRWebAddress'
		end
        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Email', @Action, 
            @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxCompanyKeyId,@TrxPersonKeyId,@Emai_EmailAddress,@Emai_PRWebAddress
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO

/* ************************************************************
 * Name:   dbo.trg_Address_ioupd
 * 
 * Table:  Address
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Custom INSTEAD OF UPDATE trigger;
 *          This is primarily based upon our Auto-generated 
 *          structure, but special handling must be done to 
 *          determine if a company or a person record is being
 *          updated. 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Address_ioupd]
GO

CREATE TRIGGER dbo.trg_Address_ioupd
ON Address
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
    Declare @addr_AddressId int
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

    SELECT @UserId = i.addr_UpdatedBy, @addr_AddressId = i.addr_AddressId
        FROM Inserted i
        INNER JOIN deleted d ON i.addr_AddressId = d.addr_AddressId

    SELECT @TrxKeyId = 
        case 
            when adli_PersonId IS NOT NULL Then adli_PersonId
            else adli_CompanyId
        end                
        FROM Address_Link 
        WHERE adli_AddressId = @addr_AddressId
    -- if there is nothing to update, just return
	IF (@TrxKeyId IS NULL)
		RETURN

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE (prtx_CompanyId = @TrxKeyId or prtx_PersonId = @TrxKeyId)
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (Addr_Address1) OR
        Update (Addr_Address2) OR
        Update (Addr_Address3) OR
        Update (Addr_Address4) OR
        Update (Addr_Address5) OR
        Update (Addr_PostCode) OR
        Update (addr_uszipplusfour) OR
        Update (addr_PRCityId) OR
        Update (addr_PRCounty) OR
        Update (addr_PRZone) OR
        Update (addr_PRPublish) OR
        Update (addr_PRAttentionLinePersonId) OR
        Update (addr_PRAttentionLineCustom) OR
        Update (addr_PRDescription) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Address ' + convert(varchar,@addr_AddressId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId smallint, insText Text, delText Text)

        Declare @ins_Addr_Address1 nchar(40), @del_Addr_Address1 nchar(40)
        Declare @ins_Addr_Address2 nchar(40), @del_Addr_Address2 nchar(40)
        Declare @ins_Addr_Address3 nchar(40), @del_Addr_Address3 nchar(40)
        Declare @ins_Addr_Address4 nchar(40), @del_Addr_Address4 nchar(40)
        Declare @ins_Addr_Address5 nchar(40), @del_Addr_Address5 nchar(40)
        Declare @ins_Addr_PostCode nchar(10), @del_Addr_PostCode nchar(10)
        Declare @ins_addr_uszipplusfour nchar(4), @del_addr_uszipplusfour nchar(4)
        Declare @ins_addr_PRCityId int, @del_addr_PRCityId int
        Declare @ins_addr_PRCounty nvarchar(30), @del_addr_PRCounty nvarchar(30)
        Declare @ins_addr_PRZone nvarchar(40), @del_addr_PRZone nvarchar(40)
        Declare @ins_addr_PRPublish nchar(1), @del_addr_PRPublish nchar(1)
        Declare @ins_addr_PRAttentionLinePersonId int, @del_addr_PRAttentionLinePersonId int
        Declare @ins_addr_PRAttentionLineCustom nvarchar(100), @del_addr_PRAttentionLineCustom nvarchar(100)
        Declare @ins_addr_PRDescription nvarchar(100), @del_addr_PRDescription nvarchar(100)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_Addr_Address1 = i.Addr_Address1, @del_Addr_Address1 = d.Addr_Address1,
            @ins_Addr_Address2 = i.Addr_Address2, @del_Addr_Address2 = d.Addr_Address2,
            @ins_Addr_Address3 = i.Addr_Address3, @del_Addr_Address3 = d.Addr_Address3,
            @ins_Addr_Address4 = i.Addr_Address4, @del_Addr_Address4 = d.Addr_Address4,
            @ins_Addr_Address5 = i.Addr_Address5, @del_Addr_Address5 = d.Addr_Address5,
            @ins_Addr_PostCode = i.Addr_PostCode, @del_Addr_PostCode = d.Addr_PostCode,
            @ins_addr_uszipplusfour = i.addr_uszipplusfour, @del_addr_uszipplusfour = d.addr_uszipplusfour,
            @ins_addr_PRCityId = i.addr_PRCityId, @del_addr_PRCityId = d.addr_PRCityId,
            @ins_addr_PRCounty = i.addr_PRCounty, @del_addr_PRCounty = d.addr_PRCounty,
            @ins_addr_PRZone = i.addr_PRZone, @del_addr_PRZone = d.addr_PRZone,
            @ins_addr_PRPublish = i.addr_PRPublish, @del_addr_PRPublish = d.addr_PRPublish,
            @ins_addr_PRAttentionLinePersonId = i.addr_PRAttentionLinePersonId, @del_addr_PRAttentionLinePersonId = d.addr_PRAttentionLinePersonId,
            @ins_addr_PRAttentionLineCustom = i.addr_PRAttentionLineCustom, @del_addr_PRAttentionLineCustom = d.addr_PRAttentionLineCustom,
            @ins_addr_PRDescription = i.addr_PRDescription, @del_addr_PRDescription = d.addr_PRDescription
        FROM Inserted i
        INNER JOIN deleted d ON i.addr_AddressId = d.addr_AddressId

        -- Addr_Address1
        IF  (  Update(Addr_Address1))
        BEGIN
            SET @OldValue = @del_Addr_Address1
            SET @NewValue = @ins_Addr_Address1
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'Addr_Address1', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Addr_Address2
        IF  (  Update(Addr_Address2))
        BEGIN
            SET @OldValue = @del_Addr_Address2
            SET @NewValue = @ins_Addr_Address2
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'Addr_Address2', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Addr_Address3
        IF  (  Update(Addr_Address3))
        BEGIN
            SET @OldValue = @del_Addr_Address3
            SET @NewValue = @ins_Addr_Address3
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'Addr_Address3', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Addr_Address4
        IF  (  Update(Addr_Address4))
        BEGIN
            SET @OldValue = @del_Addr_Address4
            SET @NewValue = @ins_Addr_Address4
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'Addr_Address4', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Addr_Address5
        IF  (  Update(Addr_Address5))
        BEGIN
            SET @OldValue = @del_Addr_Address5
            SET @NewValue = @ins_Addr_Address5
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'Addr_Address5', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- Addr_PostCode
        IF  (  Update(Addr_PostCode))
        BEGIN
            SET @OldValue = @del_Addr_PostCode
            SET @NewValue = @ins_Addr_PostCode
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'Addr_PostCode', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- addr_uszipplusfour
        IF  (  Update(addr_uszipplusfour))
        BEGIN
            SET @OldValue = @del_addr_uszipplusfour
            SET @NewValue = @ins_addr_uszipplusfour
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'addr_uszipplusfour', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- addr_PRCityId
        IF  (  Update(addr_PRCityId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prci_city FROM PRCity
                WHERE prci_CityId = @ins_addr_PRCityId
            SET @NewValue = COALESCE(@NewValueTemp, convert(varchar(3000), @ins_addr_PRCityId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prci_city FROM PRCity
                WHERE prci_CityId = @del_addr_PRCityId
            SET @OldValue = COALESCE(@NewValueTemp, convert(varchar(3000), @del_addr_PRCityId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'addr_PRCityId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- addr_PRCounty
        IF  (  Update(addr_PRCounty))
        BEGIN
            SET @OldValue = @del_addr_PRCounty
            SET @NewValue = @ins_addr_PRCounty
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'addr_PRCounty', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- addr_PRZone
        IF  (  Update(addr_PRZone))
        BEGIN
            SET @OldValue = @del_addr_PRZone
            SET @NewValue = @ins_addr_PRZone
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'addr_PRZone', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- addr_PRPublish
        IF  (  Update(addr_PRPublish))
        BEGIN
            SET @OldValue = @del_addr_PRPublish
            SET @NewValue = @ins_addr_PRPublish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'addr_PRPublish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- addr_PRAttentionLinePersonId
        IF  (  Update(addr_PRAttentionLinePersonId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_FirstName + ' ' + pers_LastName FROM Person
                WHERE pers_PersonId = @ins_addr_PRAttentionLinePersonId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @ins_addr_PRAttentionLinePersonId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_FirstName + ' ' + pers_LastName FROM Person
                WHERE pers_PersonId = @del_addr_PRAttentionLinePersonId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(3000), @del_addr_PRAttentionLinePersonId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'addr_PRAttentionLinePersonId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- addr_PRAttentionLineCustom
        IF  (  Update(addr_PRAttentionLineCustom))
        BEGIN
            SET @OldValue = @del_addr_PRAttentionLineCustom
            SET @NewValue = @ins_addr_PRAttentionLineCustom
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'addr_PRAttentionLineCustom', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- addr_PRDescription
        IF  (  Update(addr_PRDescription))
        BEGIN
            SET @OldValue = @del_addr_PRDescription
            SET @NewValue = @ins_addr_PRDescription
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'addr_PRDescription', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        DROP TABLE #TextTable
    END
    IF (@Err = 0) 
    BEGIN
        UPDATE Address SET 
        Address.Addr_AddressId=i.Addr_AddressId, 
        Address.Addr_Address1=i.Addr_Address1, 
        Address.Addr_Address2=i.Addr_Address2, 
        Address.Addr_Address3=i.Addr_Address3, 
        Address.Addr_Address4=i.Addr_Address4, 
        Address.Addr_Address5=i.Addr_Address5, 
        Address.Addr_City=i.Addr_City, 
        Address.Addr_State=i.Addr_State, 
        Address.Addr_Country=i.Addr_Country, 
        Address.Addr_PostCode=i.Addr_PostCode, 
        Address.Addr_CreatedBy=i.Addr_CreatedBy, 
        Address.Addr_CreatedDate=dbo.ufn_GetAccpacDate(i.Addr_CreatedDate), 
        Address.Addr_UpdatedBy=i.Addr_UpdatedBy, 
        Address.Addr_UpdatedDate=dbo.ufn_GetAccpacDate(i.Addr_UpdatedDate), 
        Address.Addr_TimeStamp=dbo.ufn_GetAccpacDate(i.Addr_TimeStamp), 
        Address.Addr_Deleted=i.Addr_Deleted, 
        Address.Addr_SegmentID=i.Addr_SegmentID, 
        Address.Addr_ChannelID=i.Addr_ChannelID, 
        Address.addr_uszipplusfour=i.addr_uszipplusfour, 
        Address.addr_PRCityId=i.addr_PRCityId, 
        Address.addr_PRCounty=i.addr_PRCounty, 
        Address.addr_PRZone=i.addr_PRZone, 
        Address.addr_PRReplicatedFromId=i.addr_PRReplicatedFromId, 
        Address.addr_PRPublish=i.addr_PRPublish, 
        Address.addr_PRAttentionLinePersonId=i.addr_PRAttentionLinePersonId, 
        Address.addr_PRAttentionLineCustom=i.addr_PRAttentionLineCustom, 
        Address.addr_PRDescription=i.addr_PRDescription
        FROM inserted i 
          INNER JOIN Address ON i.addr_AddressId=Address.addr_AddressId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_Address_Link_ioupd
 * 
 * Table:  Address_Link
 * Action: INSTEAD OF UPDATE
 * 
 * Description: Custom INSTEAD OF UPDATE trigger
 *          This is primarily based upon our Auto-generated 
 *          structure, but special handling must be done to 
 *          determine if a company or a person record is being
 *          updated. 
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_Link_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Address_Link_ioupd]
GO

CREATE TRIGGER dbo.trg_Address_Link_ioupd
ON Address_Link
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
    Declare @AdLi_AddressLinkId int
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

    SELECT @UserId = i.AdLi_UpdatedBy, @AdLi_AddressLinkId = i.AdLi_AddressLinkId
        FROM Inserted i
        INNER JOIN deleted d ON i.AdLi_AddressLinkId = d.AdLi_AddressLinkId

    SELECT @TrxKeyId = 
        case 
            when i.adli_PersonId IS NOT NULL Then i.adli_PersonId
            else i.adli_CompanyId
        end                
        FROM Inserted i
        INNER JOIN deleted d ON i.AdLi_AddressLinkId = d.AdLi_AddressLinkId

    -- if there is nothing to update, just return
	IF (@TrxKeyId IS NULL)
		RETURN

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
        @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE (prtx_CompanyId = @TrxKeyId or prtx_PersonId = @TrxKeyId)
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL

    IF (
        Update (AdLi_Type) or
        Update (AdLi_PRDefaultMailing) or
        Update (AdLi_PRDefaultShipping) or
        Update (AdLi_PRDefaultBilling) or
        Update (AdLi_PRDefaultListing) or
        Update (AdLi_PRDefaultTAX) or 
        Update (AdLi_PRDefaultTES) or
        Update (AdLi_PRDefaultJeopardy) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Address ' + convert(varchar,@AdLi_AddressLinkId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END
        Create TABLE #TextTable(TransactionId smallint, insText Text, delText Text)

        Declare @ins_AdLi_Type nvarchar(255), @del_AdLi_Type nvarchar(255)
        Declare @ins_AdLi_PRDefaultMailing nchar(1), @del_AdLi_PRDefaultMailing nchar(1)
        Declare @ins_AdLi_PRDefaultShipping nchar(1), @del_AdLi_PRDefaultShipping nchar(1)
        Declare @ins_AdLi_PRDefaultBilling nchar(1), @del_AdLi_PRDefaultBilling nchar(1)
        Declare @ins_AdLi_PRDefaultListing nchar(1), @del_AdLi_PRDefaultListing nchar(1)
        Declare @ins_AdLi_PRDefaultTax nchar(1), @del_AdLi_PRDefaultTax nchar(1)
        Declare @ins_AdLi_PRDefaultTES nchar(1), @del_AdLi_PRDefaultTES nchar(1)
        Declare @ins_AdLi_PRDefaultJeopardy nchar(1), @del_AdLi_PRDefaultJeopardy nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @ins_AdLi_Type = i.AdLi_Type, @del_AdLi_Type = d.AdLi_Type,
            @ins_AdLi_PRDefaultMailing = i.AdLi_PRDefaultMailing, @del_AdLi_PRDefaultMailing = d.AdLi_PRDefaultMailing,
            @ins_AdLi_PRDefaultShipping = i.AdLi_PRDefaultShipping, @del_AdLi_PRDefaultShipping = d.AdLi_PRDefaultShipping,
            @ins_AdLi_PRDefaultBilling = i.AdLi_PRDefaultBilling, @del_AdLi_PRDefaultBilling = d.AdLi_PRDefaultBilling,
            @ins_AdLi_PRDefaultListing = i.AdLi_PRDefaultListing, @del_AdLi_PRDefaultListing = d.AdLi_PRDefaultListing,
            @ins_AdLi_PRDefaultTax = i.AdLi_PRDefaultTax, @del_AdLi_PRDefaultTax = d.AdLi_PRDefaultTax,
            @ins_AdLi_PRDefaultTES = i.AdLi_PRDefaultTES, @del_AdLi_PRDefaultTES = d.AdLi_PRDefaultTES,
            @ins_AdLi_PRDefaultJeopardy = i.AdLi_PRDefaultJeopardy, @del_AdLi_PRDefaultJeopardy = d.AdLi_PRDefaultJeopardy
        FROM Inserted i
        INNER JOIN deleted d ON i.AdLi_AddressLinkId = d.AdLi_AddressLinkId

        -- AdLi_Type
        IF  (  Update(AdLi_Type))
        BEGIN
            SET @OldValue = @del_AdLi_Type
            SET @NewValue = @ins_AdLi_Type
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'AdLi_Type', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- AdLi_PRDefaultMailing
        IF  (  Update(AdLi_PRDefaultMailing))
        BEGIN
            SET @OldValue = @del_AdLi_PRDefaultMailing
            SET @NewValue = @ins_AdLi_PRDefaultMailing
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'AdLi_PRDefaultMailing', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- AdLi_PRDefaultShipping
        IF  (  Update(AdLi_PRDefaultShipping))
        BEGIN
            SET @OldValue = @del_AdLi_PRDefaultShipping
            SET @NewValue = @ins_AdLi_PRDefaultShipping
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'AdLi_PRDefaultShipping', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- AdLi_PRDefaultBilling
        IF  (  Update(AdLi_PRDefaultBilling))
        BEGIN
            SET @OldValue = @del_AdLi_PRDefaultBilling
            SET @NewValue = @ins_AdLi_PRDefaultBilling
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'AdLi_PRDefaultBilling', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- AdLi_PRDefaultListing
        IF  (  Update(AdLi_PRDefaultListing))
        BEGIN
            SET @OldValue = @del_AdLi_PRDefaultListing
            SET @NewValue = @ins_AdLi_PRDefaultListing
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'AdLi_PRDefaultListing', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- AdLi_PRDefaultTax
        IF  (  Update(AdLi_PRDefaultTax))
        BEGIN
            SET @OldValue = @del_AdLi_PRDefaultTax
            SET @NewValue = @ins_AdLi_PRDefaultTax
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'AdLi_PRDefaultTax', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- AdLi_PRDefaultTES
        IF  (  Update(AdLi_PRDefaultTES))
        BEGIN
            SET @OldValue = @del_AdLi_PRDefaultTES
            SET @NewValue = @ins_AdLi_PRDefaultTES
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'AdLi_PRDefaultTES', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- AdLi_PRDefaultJeopardy
        IF  (  Update(AdLi_PRDefaultJeopardy))
        BEGIN
            SET @OldValue = @del_AdLi_PRDefaultJeopardy
            SET @NewValue = @ins_AdLi_PRDefaultJeopardy
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'AdLi_PRDefaultJeopardy', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END


        DROP TABLE #TextTable
    END
    IF (@Err = 0) 
    BEGIN
        UPDATE Address_Link SET 
        Address_Link.AdLi_AddressLinkId=i.AdLi_AddressLinkId, 
        Address_Link.AdLi_AddressId=i.AdLi_AddressId, 
        Address_Link.AdLi_CompanyID=i.AdLi_CompanyID, 
        Address_Link.AdLi_PersonID=i.AdLi_PersonID, 
        Address_Link.AdLi_Type=i.AdLi_Type, 
        Address_Link.AdLi_PRDefaultMailing=i.AdLi_PRDefaultMailing, 
        Address_Link.AdLi_PRDefaultShipping=i.AdLi_PRDefaultShipping, 
        Address_Link.AdLi_PRDefaultBilling=i.AdLi_PRDefaultBilling, 
        Address_Link.AdLi_PRDefaultListing=i.AdLi_PRDefaultListing, 
        Address_Link.AdLi_PRDefaultTax=i.AdLi_PRDefaultTax, 
        Address_Link.AdLi_PRDefaultTES=i.AdLi_PRDefaultTES, 
        Address_Link.AdLi_PRDefaultJeopardy=i.AdLi_PRDefaultJeopardy, 
        Address_Link.AdLi_CreatedBy=i.AdLi_CreatedBy, 
        Address_Link.AdLi_CreatedDate=dbo.ufn_GetAccpacDate(i.AdLi_CreatedDate), 
        Address_Link.AdLi_UpdatedBy=i.AdLi_UpdatedBy, 
        Address_Link.AdLi_UpdatedDate=dbo.ufn_GetAccpacDate(i.AdLi_UpdatedDate), 
        Address_Link.AdLi_TimeStamp=dbo.ufn_GetAccpacDate(i.AdLi_TimeStamp), 
        Address_Link.AdLi_Deleted=i.AdLi_Deleted
        FROM inserted i 
          INNER JOIN Address_Link ON i.AdLi_AddressLinkId=Address_Link.AdLi_AddressLinkId
    END
END
GO
/* ************************************************************
 * Name:   dbo.trg_Address_Link_insdel
 * 
 * Table:  Address_Link
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_Link_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Address_Link_insdel]
GO

CREATE TRIGGER dbo.trg_Address_Link_insdel
ON Address_Link
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxCompanyKeyId int
    Declare @TrxPersonKeyId int
    Declare @AdLi_AddressLinkId int
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
    Declare @ProcessTable TABLE(ProcessAction varchar(10), adli_CompanyId int, adli_PersonId int, AdLi_AddressId int, AdLi_Type nvarchar(255))
    INSERT INTO @ProcessTable
        SELECT 'Insert',adli_CompanyId,adli_PersonId,AdLi_AddressId,AdLi_Type
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',adli_CompanyId,adli_PersonId,AdLi_AddressId,AdLi_Type
        FROM Deleted


    Declare @AdLi_AddressId int
    Declare @AdLi_Type nvarchar(255)

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, adli_CompanyId,adli_PersonId,AdLi_AddressId,AdLi_Type
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxCompanyKeyId,@TrxPersonKeyId,@AdLi_AddressId,@AdLi_Type
    WHILE @@Fetch_Status=0
    BEGIN
    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
        SET @prtx_TransactionId = NULL
        SELECT @prtx_TransactionId = prtx_TransactionId,
            @UserId = prtx_UpdatedBy
        FROM PRTransaction
        WHERE (prtx_CompanyId = @TrxCompanyKeyId or prtx_PersonId = @TrxPersonKeyId)
            AND prtx_Status = 'O'
            AND prtx_Deleted IS NULL

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Address ' + convert(varchar,@AdLi_AddressLinkId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = COALESCE(RTRIM(addr_address1), ', ') + 
								COALESCE(', ' + RTRIM(prci_city) , ', ') + 
								COALESCE(', ' + RTRIM(prst_state), ', ') + 
								COALESCE(', ' + RTRIM(addr_postcode) , ', ') + 
								COALESCE(', ' + adli_TypeDisplay, '')
			FROM vPRAddress
            WHERE addr_AddressId = @AdLi_AddressId
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @AdLi_AddressId))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 
            'addr_Address1,prci_City, prst_State, addr_postcode, AdLi_Type', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxCompanyKeyId,@TrxPersonKeyId,@AdLi_AddressId,@AdLi_Type
    End
    Close crs
    DEALLOCATE crs
    SET NOCOUNT OFF
END
GO

/* ************************************************************
 * Name:   dbo.trg_PRCompanyRelationship_insdel
 * 
 * Table:  PRCompanyRelationship
 * Action: FOR INSERT, DELETE
 * 
 * Description: Modified Auto-generat FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyRelationship_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_PRCompanyRelationship_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyRelationship_insdel
ON PRCompanyRelationship
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

--    Declare @TrxKeyId int
    Declare @prcr_CompanyRelationshipId int
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
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prcr_LeftCompanyId int, prcr_RightCompanyId int, prcr_Type nvarchar(40), prcr_OwnershipPct numeric)
    INSERT INTO @ProcessTable
        SELECT 'Insert',prcr_LeftCompanyId,prcr_RightCompanyId,prcr_Type,prcr_OwnershipPct
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prcr_LeftCompanyId,prcr_RightCompanyId,prcr_Type,prcr_OwnershipPct
        FROM Deleted


    Declare @prcr_LeftCompanyId int
    Declare @prcr_RightCompanyId int
    Declare @prcr_Type nvarchar(40)
    Declare @prcr_OwnershipPct numeric

    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prcr_LeftCompanyId,prcr_RightCompanyId,prcr_Type,prcr_OwnershipPct
        FROM @ProcessTable
    BEGIN TRY
		OPEN crs
		FETCH NEXT FROM crs INTO @Action, @prcr_LeftCompanyId,@prcr_RightCompanyId,@prcr_Type,@prcr_OwnershipPct
		WHILE @@Fetch_Status=0
		BEGIN
			if (@prcr_Type = '27' or @prcr_Type = '28')
			begin
				SET @prtx_TransactionId = NULL
				SELECT @prtx_TransactionId = prtx_TransactionId,
					@UserId = prtx_UpdatedBy
				FROM PRTransaction
				WHERE prtx_CompanyId = @prcr_LeftCompanyId
					AND prtx_Status = 'O'
					AND prtx_Deleted IS NULL

				IF (@prtx_TransactionId IS NULL)
				BEGIN
					SET @Msg = 'Changes Failed.  Company Relationship ' + convert(varchar,@prcr_CompanyRelationshipId) + ' values can only be changed if a transaction is open.'
					ROLLBACK
					RAISERROR (@Msg, 16, 1)
					Return
				END

				SET @NewValueTemp = NULL
				SELECT @NewValueTemp = comp_name FROM Company
						WHERE comp_companyid = @prcr_LeftCompanyId
				SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcr_LeftCompanyId))
				SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

				SET @NewValueTemp = NULL
				SELECT @NewValueTemp = comp_name FROM Company
						WHERE comp_companyid = @prcr_RightCompanyId
				SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcr_RightCompanyId))
				SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

				SET @NewValueTemp = convert(varchar(50), @prcr_Type)
				SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

				SET @NewValueTemp = convert(varchar(50), @prcr_OwnershipPct)
				SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp)

				-- Assume Inserted
				SET @OldValue = NULL
				IF (@Action = 'Delete')
				BEGIN
					SET @OldValue = @NewValue
					SET @NewValue = NULL
				End
				exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Relationship', @Action, 
					'comp_name,comp_name,prcr_Type,prcr_OwnershipPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
			end
			FETCH NEXT FROM crs INTO @Action, @prcr_LeftCompanyId,@prcr_RightCompanyId,@prcr_Type,@prcr_OwnershipPct
		End
    END TRY
    BEGIN CATCH
		Close crs
		DEALLOCATE crs
		exec usp_RethrowError
    END CATCH
	Close crs
	DEALLOCATE crs
    SET NOCOUNT OFF
END
GO
