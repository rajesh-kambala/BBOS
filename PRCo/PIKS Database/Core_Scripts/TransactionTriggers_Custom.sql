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
    Declare @prtx_TransactionId int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @Phon_PhoneId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @PersonID int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = plink_RecordID,
           @UserId = i.Phon_UpdatedBy, 
           @Phon_PhoneId = i.Phon_PhoneId
     FROM Inserted i
          INNER JOIN deleted d ON i.Phon_PhoneId = d.Phon_PhoneId
		  INNER JOIN PhoneLink ON i.Phon_PhoneID = plink_PhoneID

    -- if there is nothing to update, just return
	IF (@TrxKeyId IS NULL)
		RETURN

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT TOP 1
	       @prtx_TransactionId = prtx_TransactionId,
           @UserId = prtx_UpdatedBy
      FROM PRTransaction WITH (NOLOCK)
     WHERE (prtx_CompanyId = @TrxKeyId OR prtx_PersonId = @TrxKeyId)
       AND prtx_Status = 'O'
       AND prtx_Deleted IS NULL
  ORDER BY ISNULL(prtx_PersonId, 0) DESC;

    IF (
        Update (Phon_CountryCode) OR
        Update (Phon_AreaCode) OR
        Update (Phon_Number) OR
        Update (phon_PRDescription) OR
        Update (phon_PRExtension) OR
        Update (phon_PRInternational) OR
        Update (phon_PRCityCode) OR
        Update (phon_PRPublish) OR
        Update (phon_PRPreferredPublished) OR
        Update (phon_PRPreferredInternal) OR
        Update (phon_PRDisconnected) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Phone ' + convert(varchar,@Phon_PhoneId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_Phon_CountryCode nchar(5), @del_Phon_CountryCode nchar(5)
        Declare @ins_Phon_AreaCode nchar(20), @del_Phon_AreaCode nchar(20)
        Declare @ins_Phon_Number nchar(34), @del_Phon_Number nchar(34)
        Declare @ins_phon_PRDescription nvarchar(34), @del_phon_PRDescription nvarchar(34)
        Declare @ins_phon_PRExtension nvarchar(5), @del_phon_PRExtension nvarchar(5)
        Declare @ins_phon_PRInternational nchar(1), @del_phon_PRInternational nchar(1)
        Declare @ins_phon_PRCityCode nvarchar(5), @del_phon_PRCityCode nvarchar(5)
        Declare @ins_phon_PRPublish nchar(1), @del_phon_PRPublish nchar(1)
        Declare @ins_phon_PRPreferredPublished nchar(1), @del_phon_PRPreferredPublished nchar(1)
        Declare @ins_phon_PRPreferredInternal nchar(1), @del_phon_PRPreferredInternal nchar(1)
        Declare @ins_phon_PRDisconnected nchar(1), @del_phon_PRDisconnected nchar(1)

        -- For each updated field value create a transaction detail record
        SELECT @PersonID = CASE plink_EntityID WHEN 13 THEN plink_RecordID ELSE NULL END,
		       @CompanyId = CASE plink_EntityID WHEN 5 THEN plink_RecordID ELSE i.phon_CompanyID END,
               @ins_Phon_CountryCode = i.Phon_CountryCode, @del_Phon_CountryCode = d.Phon_CountryCode,
               @ins_Phon_AreaCode = i.Phon_AreaCode, @del_Phon_AreaCode = d.Phon_AreaCode,
               @ins_Phon_Number = i.Phon_Number, @del_Phon_Number = d.Phon_Number,
               @ins_phon_PRDescription = i.phon_PRDescription, @del_phon_PRDescription = d.phon_PRDescription,
               @ins_phon_PRExtension = i.phon_PRExtension, @del_phon_PRExtension = d.phon_PRExtension,
               @ins_phon_PRInternational = i.phon_PRInternational, @del_phon_PRInternational = d.phon_PRInternational,
               @ins_phon_PRCityCode = i.phon_PRCityCode, @del_phon_PRCityCode = d.phon_PRCityCode,
               @ins_phon_PRPublish = i.phon_PRPublish, @del_phon_PRPublish = d.phon_PRPublish,
			   @ins_phon_PRPreferredPublished = i.phon_PRPreferredPublished, @del_phon_PRPreferredPublished = d.phon_PRPreferredPublished,
			   @ins_phon_PRPreferredInternal = i.phon_PRPreferredInternal, @del_phon_PRPreferredInternal = d.phon_PRPreferredInternal,
               @ins_phon_PRDisconnected = i.phon_PRDisconnected, @del_phon_PRDisconnected = d.phon_PRDisconnected
          FROM Inserted i
               INNER JOIN deleted d ON i.Phon_PhoneId = d.Phon_PhoneId
               INNER JOIN PhoneLink ON i.Phon_PhoneID = plink_PhoneID
			   
		DECLARE @ColumnPrefix varchar(20) = ''

		IF (@PersonID IS NOT NULL) BEGIN
			SET @ColumnPrefix = 'BB #' + CAST(@CompanyId AS varchar(10)) + ' - ';
		END
		
		SET @NewValue = ISNULL(RTRIM(@ins_Phon_CountryCode), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_Phon_AreaCode), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_Phon_Number), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_phon_PRExtension), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_phon_PRDescription), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_phon_PRPreferredInternal), 'N')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_phon_PRPublish), 'N')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_phon_PRPreferredPublished), 'N')
	
		SET @OldValue = ISNULL(RTRIM(@del_Phon_CountryCode), '')
		SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_Phon_AreaCode), '')
		SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_Phon_Number), '')
		SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_phon_PRExtension), '')
		SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_phon_PRDescription), '')
		SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_phon_PRPreferredInternal), 'N')
		SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_phon_PRPublish), 'N')
		SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_phon_PRPreferredPublished), 'N')

        IF  (@OldValue != @NewValue)
        BEGIN
			SET @Caption = @ColumnPrefix + 'Country Code, Area Code, Phone Number, Extension, Description, Preferred Internal, Publish, Preferred Published'
            EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- phon_PRInternational
        IF  (  Update(phon_PRInternational))
        BEGIN
            SET @OldValue = @del_phon_PRInternational
            SET @NewValue = @ins_phon_PRInternational
			SET @Caption = @ColumnPrefix + 'International'
            EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- phon_PRCityCode
        IF  (  Update(phon_PRCityCode))
        BEGIN
            SET @OldValue = @del_phon_PRCityCode
            SET @NewValue = @ins_phon_PRCityCode
			SET @Caption = @ColumnPrefix + 'City Code'
            EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- phon_PRDisconnected
        IF  (  Update(phon_PRDisconnected))
        BEGIN
            SET @OldValue = @del_phon_PRDisconnected
            SET @NewValue = @ins_phon_PRDisconnected
			SET @Caption = @ColumnPrefix + 'Disconnected'
            EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, @ColumnPrefix, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
    END
    
    UPDATE Phone SET 
			Phone.Phon_PhoneId=i.Phon_PhoneId, 
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
			Phone.phon_PRPreferredInternal=i.phon_PRPreferredInternal,
			Phone.phon_PRPreferredPublished=i.phon_PRPreferredPublished,
			Phone.phon_PRIsPhone=i.phon_PRIsPhone,
			Phone.phon_PRIsFax=i.phon_PRIsFax,
			Phone.phon_CompanyID=i.phon_CompanyID, 
			Phone.phon_PRReplicatedFromId=i.phon_PRReplicatedFromId
    FROM inserted i 
         INNER JOIN Phone ON i.Phon_PhoneId=Phone.Phon_PhoneId;

END
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PhoneLink_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_PhoneLink_ioupd]
GO

CREATE TRIGGER dbo.trg_PhoneLink_ioupd
ON PhoneLink
INSTEAD OF UPDATE AS
BEGIN
    SET NOCOUNT ON

	IF EXISTS (
		SELECT 1 
		FROM inserted ins 
		INNER JOIN deleted del ON ins.PLink_LinkID = del.PLink_LinkID
		WHERE (ins.PLink_EntityID <> del.PLink_EntityID) OR (ins.PLink_RecordID <> del.PLink_RecordID))
	BEGIN
		RAISERROR ('You are not allowed to modify any of the following columns: PLink_EntityID, PLink_RecordID',16, 1);
	END



    Declare @prtx_TransactionId int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @Phon_PhoneId int
	Declare @EntityId int
    Declare @UserId int
    Declare @CompanyId int
    Declare @PersonID int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.plink_RecordID,
	       @EntityId = i.plink_EntityID,
           @UserId = i.plink_UpdatedBy, 
           @Phon_PhoneId = i.plink_PhoneId
     FROM Inserted i
          INNER JOIN deleted d ON i.PLink_LinkID = d.PLink_LinkID

    -- if there is nothing to update, just return
	IF (@TrxKeyId IS NULL)
		RETURN

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT TOP 1
	       @prtx_TransactionId = prtx_TransactionId,
           @UserId = prtx_UpdatedBy
      FROM PRTransaction WITH (NOLOCK)
     WHERE (prtx_CompanyId = @TrxKeyId OR prtx_PersonId = @TrxKeyId)
       AND prtx_Status = 'O'
       AND prtx_Deleted IS NULL
  ORDER BY ISNULL(prtx_PersonId, 0) DESC;

    IF (
        Update (PLink_Type))
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Phone ' + convert(varchar,@Phon_PhoneId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_PLink_EntityID int, @del_PLink_EntityID int
        Declare @ins_PLink_RecordID int, @del_PLink_RecordID int
        Declare @ins_PLink_Type varchar(50), @del_PLink_Type varchar(40)
        Declare @ins_PLink_PhoneId int, @del_PLink_PhoneId int

        -- For each updated field value create a transaction detail record
        SELECT @PersonID = CASE i.plink_EntityID WHEN 13 THEN i.plink_RecordID ELSE NULL END,
		       @CompanyId = CASE i.plink_EntityID WHEN 5 THEN i.plink_RecordID ELSE phon_CompanyID END,
               @ins_PLink_EntityID = i.PLink_EntityID, @del_PLink_EntityID = d.PLink_EntityID,
               @ins_PLink_RecordID = i.PLink_RecordID, @del_PLink_RecordID = d.PLink_RecordID,
               @ins_PLink_Type = i.PLink_Type, @del_PLink_Type = d.PLink_Type,
               @ins_PLink_PhoneId = i.PLink_PhoneId, @del_PLink_PhoneId = d.PLink_PhoneId
          FROM Inserted i
		       INNER JOIN Phone ON i.plink_PhoneID = phon_PhoneID
               INNER JOIN deleted d ON i.PLink_LinkID = d.PLink_LinkID

		DECLARE @ColumnPrefix varchar(20) = ''

		IF (@EntityId = 5) BEGIN
			SET @NewValue = dbo.ufn_GetCustomCaptionValue('Phon_TypeCompany', @ins_PLink_Type, 'en-us')
			SET @OldValue = dbo.ufn_GetCustomCaptionValue('Phon_TypeCompany', @del_PLink_Type, 'en-us')
		END ELSE BEGIN
			SET @NewValue = dbo.ufn_GetCustomCaptionValue('Phon_TypePerson', @ins_PLink_Type, 'en-us')
			SET @OldValue = dbo.ufn_GetCustomCaptionValue('Phon_TypePerson', @del_PLink_Type, 'en-us')
			SET @ColumnPrefix = 'BB #' + CAST(@CompanyId AS varchar(10)) + ' - ';
		END
	
	
        IF  (@OldValue != @NewValue)
        BEGIN
			SET @Caption = @ColumnPrefix + 'Type'
            EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END		
		
		
    END
    
    UPDATE PhoneLink SET 
			PhoneLink.PLink_LinkID=i.PLink_LinkID, 
			PhoneLink.PLink_EntityID=i.PLink_EntityID, 
			PhoneLink.PLink_RecordID=i.PLink_RecordID, 
			PhoneLink.PLink_Type=i.PLink_Type, 
			PhoneLink.PLink_PhoneId=i.PLink_PhoneId, 
			PhoneLink.PLink_CreatedBy=i.PLink_CreatedBy, 
			PhoneLink.PLink_CreatedDate=dbo.ufn_GetAccpacDate(i.PLink_CreatedDate), 
			PhoneLink.PLink_UpdatedBy=i.PLink_UpdatedBy, 
			PhoneLink.PLink_UpdatedDate=dbo.ufn_GetAccpacDate(i.PLink_UpdatedDate), 
			PhoneLink.PLink_TimeStamp=dbo.ufn_GetAccpacDate(i.PLink_TimeStamp), 
			PhoneLink.PLink_Deleted=i.PLink_Deleted
    FROM inserted i 
         INNER JOIN PhoneLink ON i.PLink_LinkID = PhoneLink.PLink_LinkID;

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
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PhoneLink_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_PhoneLink_insdel]
GO

CREATE TRIGGER dbo.trg_PhoneLink_insdel
ON PhoneLink
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
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

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE (
		ndx int identity(1,1) primary key,
		ProcessAction varchar(10), 
		Phon_CompanyId int, 
		Phon_PersonId int, 
		Phon_Type nvarchar(40), 
		Phon_CountryCode nvarchar(5), 
		Phon_AreaCode nchar(20), 
		Phon_Number nchar(34),
		Phon_PRExtension nvarchar(15),
		Phon_PRDescription nvarchar(34),
		Phon_PRPreferredInternal nchar(1), 
		Phon_PRPreferredPublished nchar(1), 
		Phon_PRPublish nchar(1))
		
    INSERT INTO @ProcessTable
        SELECT 'Insert',
		       CASE plink_EntityID WHEN 5 THEN plink_RecordID ELSE phon_CompanyID END,
			   CASE plink_EntityID WHEN 13 THEN plink_RecordID ELSE NULL END,
		       plink_Type,
		       Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_PRExtension,Phon_PRDescription,Phon_PRPreferredInternal,Phon_PRPreferredPublished,Phon_PRPublish
        FROM inserted
		     INNER JOIN Phone ON plink_PhoneID = phon_PhoneID
    INSERT INTO @ProcessTable
        SELECT 'Delete',
		       CASE plink_EntityID WHEN 5 THEN plink_RecordID ELSE phon_CompanyID END,
			   CASE plink_EntityID WHEN 13 THEN plink_RecordID ELSE NULL END,
		       plink_Type,
		       Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_PRExtension,Phon_PRDescription,Phon_PRPreferredInternal,Phon_PRPreferredPublished,Phon_PRPublish
        FROM deleted
		     INNER JOIN Phone ON plink_PhoneID = phon_PhoneID

	Declare @Phon_CountryCode nvarchar(5)
    Declare @Phon_Type nvarchar(40)
    Declare @Phon_AreaCode nchar(20)
    Declare @Phon_Number nchar(34)
	Declare @Phon_Extension nchar(15)
	Declare @Phon_Description nchar(35)
    Declare @PreferredInternal nchar(1)
    Declare @PreferredPublished nchar(1)
	Declare @Publish nchar(1)

	DECLARE @Index int, @Count int
	DECLARE @ColumnPrefix varchar(50)
	SELECT @Count = COUNT(1) FROM @ProcessTable;
	SET @Index = 0
	
	WHILE (@Index < @Count) BEGIN
		SET @Index = @Index + 1
		

		SELECT @Action = ProcessAction,
		       @TrxCompanyKeyId = Phon_CompanyId,
		       @TrxPersonKeyId = Phon_PersonId,
		       @Phon_CountryCode = Phon_CountryCode,
		       @Phon_Type = Phon_Type,
		       @Phon_AreaCode = Phon_AreaCode,
		       @Phon_Number = Phon_Number,
		       @Phon_Extension = Phon_PRExtension,
		       @Phon_Description = Phon_PRDescription,
		       @PreferredInternal = phon_PRPreferredInternal,
			   @PreferredPublished = phon_PRPreferredPublished,
			   @Publish = phon_PRPublish
          FROM @ProcessTable
         WHERE ndx = @Index;
         			
        SET @prtx_TransactionId = NULL
        SELECT TOP 1
		       @prtx_TransactionId = prtx_TransactionId,
               @UserId = prtx_UpdatedBy
          FROM PRTransaction WITH (NOLOCK)
         WHERE (prtx_CompanyId = @TrxCompanyKeyId OR prtx_PersonId = @TrxPersonKeyId)
           AND prtx_Status = 'O'
           AND prtx_Deleted IS NULL
      ORDER BY ISNULL(prtx_PersonId, 0) DESC;

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Phone ' + convert(varchar,@Phon_PhoneId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

		SET @ColumnPrefix = ''
		IF (@TrxPersonKeyId IS NULL) BEGIN
			SET @NewValue = dbo.ufn_GetCustomCaptionValue('Phon_TypeCompany', @Phon_Type, 'en-us')
		END ELSE BEGIN
			SET @ColumnPrefix = 'BB #' + CAST(@TrxCompanyKeyId AS varchar(10)) + ' - ';
			SET @NewValue = dbo.ufn_GetCustomCaptionValue('Phon_TypePerson', @Phon_Type, 'en-us')
			
		END

		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@Phon_CountryCode), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@Phon_AreaCode), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@Phon_Number), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@Phon_Extension), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@Phon_Description), '')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@PreferredInternal), 'N')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@Publish), 'N')
		SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@PreferredPublished), 'N')

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        END

		SET @Caption = @ColumnPrefix + 'Country Code, Area Code, Phone Number, Extension, Description, Preferred Internal, Publish, Preferred Published'
        EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Phone', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId

    End

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
    --Declare @Err int
    --SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @Emai_EmailId int
    Declare @UserId int
    Declare @CompanyId int
	Declare @PersonID int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = elink_RecordID,
           @UserId = i.emai_UpdatedBy, 
           @Emai_EmailId = i.Emai_EmailId
      FROM Inserted i
           INNER JOIN deleted d ON i.Emai_EmailId = d.Emai_EmailId
		   INNER JOIN EmailLink ON i.Emai_EmailId = elink_emailID;

    -- if there is nothing to update, just return
	IF (@TrxKeyId IS NULL)
		RETURN

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT TOP 1
	       @prtx_TransactionId = prtx_TransactionId,
           @UserId = prtx_UpdatedBy
      FROM PRTransaction WITH (NOLOCK)
     WHERE (prtx_CompanyId = @TrxKeyId or prtx_PersonId = @TrxKeyId)
       AND prtx_Status = 'O'
       AND prtx_Deleted IS NULL
  ORDER BY ISNULL(prtx_PersonId, 0) DESC;

    IF (
        Update (Emai_EmailAddress) OR
        Update (Emai_PRWebAddress) OR
        Update (Emai_PRDescription) OR
        Update (Emai_PRPreferredInternal) OR
        Update (Emai_PRPublish) OR
        Update (Emai_PRPreferredPublished) OR
        Update (Emai_PRSequence) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Email record ' + convert(varchar,@Emai_EmailId) + ' values can only be changed if a transaction is open.'
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_Emai_EmailAddress nvarchar(255), @del_Emai_EmailAddress nvarchar(255)
        Declare @ins_Emai_PRWebAddress nvarchar(255), @del_Emai_PRWebAddress nvarchar(255)
        Declare @ins_Emai_PRDescription nvarchar(50), @del_Emai_PRDescription nvarchar(50)
        Declare @ins_Emai_PRPreferredInternal nchar(1), @del_emai_PRPreferredInternal nchar(1)
        Declare @ins_emai_PRPreferredPublished nchar(1), @del_emai_PRPreferredPublished nchar(1)
        Declare @ins_emai_PRPublish nchar(1), @del_emai_PRPublish nchar(1)
        Declare @ins_Emai_PRSequence int, @del_Emai_PRSequence int

        -- For each updated field value create a transaction detail record
        SELECT @PersonID = CASE elink_EntityID WHEN 13 THEN elink_RecordID ELSE NULL END,
		       @CompanyId = CASE elink_EntityID WHEN 5 THEN elink_RecordID ELSE i.emai_CompanyID END,
               @ins_Emai_EmailAddress = i.Emai_EmailAddress, @del_Emai_EmailAddress = d.Emai_EmailAddress,
               @ins_Emai_PRWebAddress = i.Emai_PRWebAddress, @del_Emai_PRWebAddress = d.Emai_PRWebAddress,
               @ins_Emai_PRDescription = i.Emai_PRDescription, @del_Emai_PRDescription = d.Emai_PRDescription,
               @ins_emai_PRPreferredInternal = i.emai_PRPreferredInternal, @del_emai_PRPreferredInternal = d.emai_PRPreferredInternal,
               @ins_emai_PRPreferredPublished = i.emai_PRPreferredPublished, @del_emai_PRPreferredPublished = d.emai_PRPreferredPublished,
               @ins_emai_PRPublish = i.emai_PRPublish, @del_emai_PRPublish = d.emai_PRPublish,
               @ins_Emai_PRSequence = i.Emai_PRSequence, @del_Emai_PRSequence = d.Emai_PRSequence
          FROM Inserted i
               INNER JOIN deleted d ON i.Emai_EmailId = d.Emai_EmailId
			   LEFT OUTER JOIN EmailLink ON i.Emai_EmailId = elink_emailID;

		DECLARE @ColumnPrefix varchar(20) = ''

		IF (@PersonID IS NOT NULL) BEGIN
			SET @ColumnPrefix = 'BB #' + CAST(@CompanyId AS varchar(10)) + ' - ';
		END

        -- Emai_EmailAddress
		IF (
			Update (Emai_EmailAddress) OR
			Update (Emai_PRWebAddress) OR
			(ISNULL(@ins_emai_PRPreferredInternal, 'N') != ISNULL(@del_emai_PRPreferredInternal, 'N')) OR
			(ISNULL(@ins_emai_PRPreferredPublished, 'N') != ISNULL(@del_emai_PRPreferredPublished, 'N')) OR
			(ISNULL(@ins_emai_PRPublish, 'N') != ISNULL(@del_emai_PRPublish, 'N')))
        BEGIN


	        IF  (@ins_Emai_PRWebAddress IS NOT NULL OR @ins_Emai_PRWebAddress IS NOT NULL) BEGIN
			    SET @OldValue = RTRIM(ISNULL(@del_Emai_PRWebAddress, ''))
				SET @NewValue = RTRIM(ISNULL(@ins_Emai_PRWebAddress, ''))
				SET @Caption = @ColumnPrefix + 'Web Address'

			END ELSE BEGIN
	            SET @OldValue = RTRIM(ISNULL(@del_Emai_EmailAddress, ''))
		        SET @NewValue = RTRIM(ISNULL(@ins_Emai_EmailAddress, ''))
				SET @Caption = @ColumnPrefix + 'Email Address'
			END
			SET @Caption = @Caption + ', Preferred Internal, Publish, Preferred Published'


			SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_emai_PRPreferredInternal), 'N')
			SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_emai_PRPublish), 'N')
			SET @NewValue = @NewValue + ', ' + ISNULL(RTRIM(@ins_emai_PRPreferredPublished), 'N')

			SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_emai_PRPreferredInternal), 'N')
			SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_emai_PRPublish), 'N')
			SET @OldValue = @OldValue + ', ' + ISNULL(RTRIM(@del_emai_PRPreferredPublished), 'N')

            EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- Emai_PRDescription
        IF  (  Update(Emai_PRDescription))
        BEGIN
            SET @OldValue = @del_Emai_PRDescription
            SET @NewValue = @ins_Emai_PRDescription
			SET @Caption = @ColumnPrefix + 'Description'
            EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- Emai_PRSequence
        IF  (  Update(Emai_PRSequence))
        BEGIN
            SET @OldValue = @del_Emai_PRSequence
            SET @NewValue = @ins_Emai_PRSequence
			SET @Caption = @ColumnPrefix + 'Sequence'
            EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    
    UPDATE Email SET 
        Email.Emai_EmailId=i.Emai_EmailId, 
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
        Email.emai_PRPreferredInternal=i.emai_PRPreferredInternal, 
        Email.Emai_PRDescription=i.Emai_PRDescription, 
        Email.emai_PRPreferredPublished=i.emai_PRPreferredPublished, 
        Email.emai_PRPublish=i.emai_PRPublish, 
        Email.emai_CompanyID=i.emai_CompanyID, 
		Email.Emai_PRSequence=i.Emai_PRSequence, 
        Email.Emai_PRReplicatedFromId=i.Emai_PRReplicatedFromId
    FROM inserted i 
        INNER JOIN Email ON i.Emai_EmailId=Email.Emai_EmailId
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_EmailLink_ioupd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_EmailLink_ioupd]
GO

CREATE TRIGGER dbo.trg_EmailLink_ioupd
ON EmailLink
INSTEAD OF UPDATE AS
BEGIN

	IF EXISTS (
		SELECT 1 
		FROM inserted ins 
		INNER JOIN deleted del ON ins.ELink_LinkID = del.ELink_LinkID
		WHERE (ins.ELink_EntityID <> del.ELink_EntityID) OR (ins.ELink_RecordID <> del.ELink_RecordID))
	BEGIN
		RAISERROR ('You are not allowed to modify any of the following columns: ELink_EntityID, ELink_RecordID', 16, 1);
	END



    SET NOCOUNT ON
    --Declare @Err int
    --SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @NextID int
    Declare @TransactionDetailTypeId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @Emai_EmailId int
    Declare @UserId int
    Declare @CompanyId int
	Declare @PersonID int
	Declare @EntityId int
    Declare @Caption varchar(200)
    Declare @OldValue varchar(3000)
    Declare @NewValue varchar(3000)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Update'

    SELECT @TrxKeyId = i.elink_RecordID,
	       @EntityId = i.ELink_EntityID,
           @UserId = i.elink_UpdatedBy, 
           @Emai_EmailId = i.elink_EmailId
      FROM Inserted i
           INNER JOIN deleted d ON i.elink_EmailId = d.elink_EmailId

    -- if there is nothing to update, just return
	IF (@TrxKeyId IS NULL)
		RETURN

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT TOP 1
	       @prtx_TransactionId = prtx_TransactionId,
           @UserId = prtx_UpdatedBy
      FROM PRTransaction WITH (NOLOCK)
     WHERE (prtx_CompanyId = @TrxKeyId or prtx_PersonId = @TrxKeyId)
       AND prtx_Status = 'O'
       AND prtx_Deleted IS NULL
  ORDER BY ISNULL(prtx_PersonId, 0) DESC;

    IF (
        Update (elink_Type)  )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Email record ' + convert(varchar,@Emai_EmailId) + ' values can only be changed if a transaction is open.'
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_Emai_Type nvarchar(40), @del_Emai_Type nvarchar(40)

        -- For each updated field value create a transaction detail record
        SELECT @PersonID = CASE i.elink_EntityID WHEN 13 THEN i.elink_RecordID ELSE NULL END,
		       @CompanyId = CASE i.elink_EntityID WHEN 5 THEN i.elink_RecordID ELSE NULL END,
               @ins_Emai_Type = i.elink_Type, @del_Emai_Type = d.elink_Type
          FROM Inserted i
               INNER JOIN deleted d ON i.elink_EmailId = d.elink_EmailId

		DECLARE @ColumnPrefix varchar(20) = ''

		IF (@EntityId = 13) BEGIN
			SET @ColumnPrefix = 'BB #' + CAST(@CompanyId AS varchar(10)) + ' - ';
		END

        -- Emai_Type
        IF  (Update (elink_Type))
        BEGIN
            SET @OldValue = @del_Emai_Type
            SET @NewValue = @ins_Emai_Type
			SET @Caption = @ColumnPrefix + 'Type'
            EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
    
    UPDATE EmailLink SET 
			EmailLink.elink_LinkID=i.elink_LinkID, 
			EmailLink.elink_EntityID=i.elink_EntityID, 
			EmailLink.elink_RecordID=i.elink_RecordID, 
			EmailLink.elink_Type=i.elink_Type, 
			EmailLink.elink_EmailId=i.elink_EmailId, 
			EmailLink.elink_CreatedBy=i.elink_CreatedBy, 
			EmailLink.elink_CreatedDate=dbo.ufn_GetAccpacDate(i.elink_CreatedDate), 
			EmailLink.elink_UpdatedBy=i.elink_UpdatedBy, 
			EmailLink.elink_UpdatedDate=dbo.ufn_GetAccpacDate(i.elink_UpdatedDate), 
			EmailLink.elink_TimeStamp=dbo.ufn_GetAccpacDate(i.elink_TimeStamp), 
			EmailLink.elink_Deleted=i.elink_Deleted
    FROM inserted i 
         INNER JOIN EmailLink ON i.elink_LinkID = EmailLink.elink_LinkID;
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
CREATE OR ALTER TRIGGER dbo.trg_EmailLink_insdel
ON EmailLink
FOR INSERT, DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @prtx_TransactionId int

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

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE (
		ndx int identity(1,1) primary key,
		ProcessAction varchar(10), 
		Emai_CompanyId int, 
		Emai_PersonId int, 
		Emai_EmailAddress nvarchar(255), 
		Emai_PRWebAddress nchar(255), 
		emai_PRPreferredInternal nchar(1), 
		emai_PRPreferredPublished nchar(1), 
		emai_PRPublish nchar(1)
	)

    INSERT INTO @ProcessTable 
	    SELECT 'Insert',
		    CASE elink_EntityID WHEN 5 THEN elink_RecordID ELSE emai_CompanyID END,
			CASE elink_EntityID WHEN 13 THEN elink_RecordID ELSE NULL END,
            Emai_EmailAddress,Emai_PRWebAddress,emai_PRPreferredInternal,emai_PRPreferredPublished,emai_PRPublish
        FROM Inserted
		     INNER JOIN Email ON elink_EmailID = emai_EmailID
    INSERT INTO @ProcessTable
	    SELECT 'Delete',
		    CASE elink_EntityID WHEN 5 THEN elink_RecordID ELSE emai_CompanyID END,
			CASE elink_EntityID WHEN 13 THEN elink_RecordID ELSE NULL END,
            Emai_EmailAddress,Emai_PRWebAddress,emai_PRPreferredInternal,emai_PRPreferredPublished,emai_PRPublish
        FROM Deleted
		     INNER JOIN Email ON elink_EmailID = emai_EmailID

    Declare @Emai_EmailAddress nvarchar(255)
    Declare @Emai_PRWebAddress nvarchar(255)
    Declare @PreferredInternal nchar(1)
	Declare @PreferredPublished nchar(1)
	Declare @Publish nchar(1)

	DECLARE @Index int, @Count int
	
	SELECT @Count = COUNT(1) FROM @ProcessTable;
	SET @Index = 0
	
	WHILE (@Index < @Count) BEGIN
		SET @Index = @Index + 1

		SELECT @Action = ProcessAction,
		       @TrxCompanyKeyId = Emai_CompanyId,
		       @TrxPersonKeyId = Emai_PersonId,
		       @Emai_EmailAddress = RTRIM(Emai_EmailAddress),
		       @Emai_PRWebAddress = RTRIM(Emai_PRWebAddress),
		       @PreferredInternal = emai_PRPreferredInternal,
			   @PreferredPublished = emai_PRPreferredPublished,
			   @Publish = emai_PRPublish
          FROM @ProcessTable
         WHERE ndx = @Index;
         
        SET @prtx_TransactionId = NULL
        SELECT TOP 1
		       @prtx_TransactionId = prtx_TransactionId,
               @UserId = prtx_UpdatedBy
          FROM PRTransaction WITH (NOLOCK)
		 WHERE (prtx_CompanyId = @TrxCompanyKeyId OR prtx_PersonId = @TrxPersonKeyId)
           AND prtx_Status = 'O'
           AND prtx_Deleted IS NULL
      ORDER BY ISNULL(prtx_PersonId, 0) DESC

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Email ' + convert(varchar,@Emai_EmailId) + ' values can only be changed if a transaction is open.'
            RAISERROR (@Msg, 16, 1)
            Return
        END

        SET @NewValue = ISNULL(@Emai_EmailAddress, @Emai_PRWebAddress)
		SET @NewValue = @NewValue + ', ' + ISNULL(@PreferredInternal, 'N')
		SET @NewValue = @NewValue + ', ' + ISNULL(@Publish, 'N')
		SET @NewValue = @NewValue + ', ' + ISNULL(@PreferredPublished, 'N')


		DECLARE @ColumnPrefix varchar(20) = ''

		IF (@TrxPersonKeyId IS NOT NULL) BEGIN
			SET @ColumnPrefix = 'BB #' + CAST(@TrxCompanyKeyId AS varchar(10)) + ' - ';
		END

		SET @Caption = @ColumnPrefix + case
			when @Emai_EmailAddress is not null then 'Email Address'
			else 'Web Address'
		end
		SET @Caption = @Caption + ', Preferred Internal, Publish, Preferred Published'

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Email/Web', @Action, 
            @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
    End
    
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
        Update (addr_PRDescription) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Address ' + convert(varchar,@addr_AddressId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

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
            SELECT @NewValueTemp = prci_city FROM PRCity WITH (NOLOCK)
                WHERE prci_CityId = @ins_addr_PRCityId
            SET @NewValue = COALESCE(@NewValueTemp, convert(varchar(3000), @ins_addr_PRCityId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = prci_city FROM PRCity WITH (NOLOCK)
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
        -- addr_PRDescription
        IF  (  Update(addr_PRDescription))
        BEGIN
            SET @OldValue = @del_addr_PRDescription
            SET @NewValue = @ins_addr_PRDescription
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'addr_PRDescription', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

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
        Address.addr_PRDescription=i.addr_PRDescription,
        Address.addr_uszipfive=i.addr_uszipfive,
		Address.addr_PRLatitude=i.addr_PRLatitude,
		Address.addr_PRLongitude=i.addr_PRLongitude
        FROM inserted i 
          INNER JOIN Address ON i.addr_AddressId=Address.addr_AddressId
    END
END
GO

/* ************************************************************
 * Name:   dbo.trg_Address_insdel
 * 
 * Table:  Address_Link
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_Link_del]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Address_Link_del]
GO


CREATE TRIGGER dbo.trg_Address_Link_del
ON Address_Link
FOR DELETE AS
BEGIN

	/*
     * We are auditing the address delete here because the address_link has 
     * not yet been deleted so we can determine our context, i.e.
     * company or person.  If put this on a trigger on the address_link table,
     * the address table has already been deleted.
    */

	Declare @prtx_TransactionId int, @UserId int, @TransactionDetailTypeId int
	DECLARE @Msg varchar(1000), @OldValue varchar(1000)
 
    DECLARE @Address1 varchar(40),@Address2 varchar(40),@Address3 varchar(40),@Address4 varchar(40)
    DECLARE @PostCode varchar(10),@Description varchar(100),@CityStateCountryShort varchar(200),@PRPublish varchar(1)
    DECLARE @Type varchar(100), @County varchar(30)
	DECLARE @AddressID int, @CompanyID int, @PersonID int, @Index int, @Count int
	
    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE (
		ndx int identity(1,1),
		addr_AddressId int,
        adli_CompanyID int,
        adli_PersonID int,
        addr_Address1 varchar(40),
        addr_Address2 varchar(40),
        addr_Address3 varchar(40),
        addr_Address4 varchar(40),
        addr_PostCode varchar(10),
        addr_PRDescription varchar(100),
        CityStateCountryShort varchar(200),
        addr_PRPublish varchar(1),
        adli_Type varchar(40),
        addr_PRCounty varchar(30)
	)

    INSERT INTO @ProcessTable
    SELECT addr_AddressId, adli_CompanyID, adli_PersonID, addr_Address1, addr_Address2, addr_Address3, addr_Address4,
           addr_PostCode, addr_PRDescription, CityStateCountryShort, addr_PRPublish, adli_Type, addr_PRCounty
      FROM Deleted
           INNER JOIN Address on addr_AddressID = adli_AddressID
           INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID;
	SELECT @Count = COUNT(1) FROM @ProcessTable;

	SET @Index = 1
	WHILE (@Index <= @Count) BEGIN

		SELECT @AddressID = addr_AddressId,
               @CompanyID = adli_CompanyID,
               @PersonID = adli_PersonID,
               @Address1 = addr_Address1,
			   @Address2 = addr_Address2,
			   @Address3 = addr_Address3,
               @Address4 = addr_Address4,
			   @PostCode = addr_PostCode,
			   @Description = addr_PRDescription,
               @CityStateCountryShort = CityStateCountryShort,
               @PRPublish = ISNULL(addr_PRPublish, 'N'),
               @Type = adli_Type,
               @County = addr_PRCounty
          FROM @ProcessTable
         WHERE ndx = @Index;

		SET @prtx_TransactionId = NULL
		SELECT TOP 1
		       @prtx_TransactionId = prtx_TransactionId,
			   @UserId = prtx_UpdatedBy
		  FROM PRTransaction
		 WHERE (prtx_CompanyId = @CompanyID or prtx_PersonId = @PersonID)
		   AND prtx_Status = 'O'
		   AND prtx_Deleted IS NULL
      ORDER BY ISNULL(prtx_PersonId, 0) DESC;

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Address ' + convert(varchar, @AddressID) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

		IF (@PersonID IS NULL) BEGIN
			SET @OldValue = dbo.ufn_GetCustomCaptionValue('adli_TypeCompany', @Type, 'en-us')
		END ELSE BEGIN
			SET @OldValue = dbo.ufn_GetCustomCaptionValue('adli_TypePerson', @Type, 'en-us')
		END

		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'adli_Type', @OldValue, NULL, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'addr_Address1', @Address1, NULL, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'addr_Address2', @Address2, NULL, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'addr_Address3', @Address3, NULL, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'addr_Address4', @Address4, NULL, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'City/State/Country', @CityStateCountryShort, NULL, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'addr_PostCode', @PostCode, NULL, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'addr_PRCounty', @County, NULL, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'addr_PRDescription', @Description, NULL, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Delete', 'addr_PRPublish', @PRPublish, NULL, @UserId, @TransactionDetailTypeId

		SET @Index = @Index + 1
	END
END
Go

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
    Declare @PersonId int
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

    SELECT @TrxKeyId = case 
                          when i.adli_PersonId IS NOT NULL Then i.adli_PersonId
                          else i.adli_CompanyId
                       end                
      FROM Inserted i
           INNER JOIN deleted d ON i.AdLi_AddressLinkId = d.AdLi_AddressLinkId;

    -- if there is nothing to update, just return
	IF (@TrxKeyId IS NULL)
		RETURN

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT TOP 1
	       @prtx_TransactionId = prtx_TransactionId,
           @UserId = prtx_UpdatedBy
      FROM PRTransaction
     WHERE (prtx_CompanyId = @TrxKeyId or prtx_PersonId = @TrxKeyId)
       AND prtx_Status = 'O'
       AND prtx_Deleted IS NULL
  ORDER BY ISNULL(prtx_PersonId, 0) DESC;

    IF (
        Update (AdLi_Type) or
        Update (AdLi_PRDefaultMailing) or
        Update (AdLi_PRDefaultTAX)
        )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Address ' + convert(varchar,@AdLi_AddressLinkId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_AdLi_Type nvarchar(255), @del_AdLi_Type nvarchar(255)
        Declare @ins_AdLi_PRDefaultMailing nchar(1), @del_AdLi_PRDefaultMailing nchar(1)
        Declare @ins_AdLi_PRDefaultTax nchar(1), @del_AdLi_PRDefaultTax nchar(1)
        -- For each updated field value create a transaction detail record
        SELECT
            @PersonId = i.adli_PersonID,
            @ins_AdLi_Type = i.AdLi_Type, @del_AdLi_Type = d.AdLi_Type,
            @ins_AdLi_PRDefaultMailing = i.AdLi_PRDefaultMailing, @del_AdLi_PRDefaultMailing = d.AdLi_PRDefaultMailing,
            @ins_AdLi_PRDefaultTax = i.AdLi_PRDefaultTax, @del_AdLi_PRDefaultTax = d.AdLi_PRDefaultTax
        FROM Inserted i
        INNER JOIN deleted d ON i.AdLi_AddressLinkId = d.AdLi_AddressLinkId

        -- AdLi_Type
        IF  (  Update(AdLi_Type))
        BEGIN
            SET @OldValue = @del_AdLi_Type
            SET @NewValue = @ins_AdLi_Type
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, 'AdLi_Type', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

		IF (@PersonId IS NULL) BEGIN
			SET @OldValue = @OldValue + ISNULL(@del_AdLi_PRDefaultMailing, 'N')
			SET @NewValue = @NewValue + ISNULL(@ins_AdLi_PRDefaultMailing, 'N')

			SET @OldValue = @OldValue + ', ' + ISNULL(@del_AdLi_PRDefaultTax, 'N')
			SET @NewValue = @NewValue + ', ' + ISNULL(@ins_AdLi_PRDefaultTax, 'N')

			Set @Caption = 'Def Mailing, Def Tax'
			exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
		END
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
        Address_Link.AdLi_PRDefaultTax=i.AdLi_PRDefaultTax, 
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
 * Action: FOR INSERT
 * 
 * Description: FOR INSERT trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Address_Link_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Address_Link_insdel]
GO

CREATE TRIGGER dbo.trg_Address_Link_insdel
	ON Address_Link
	FOR INSERT AS
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

    SET @Action = 'Insert'

    -- Put the inserted and deleted records in a central table for processing
    Declare @ProcessTable TABLE(ProcessAction varchar(10), adli_CompanyId int, adli_PersonId int, AdLi_AddressId int, AdLi_Type nvarchar(255))
    INSERT INTO @ProcessTable
    SELECT 'Insert',adli_CompanyId,adli_PersonId,AdLi_AddressId,AdLi_Type
      FROM Inserted;

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
        SELECT TOP 1
		       @prtx_TransactionId = prtx_TransactionId,
               @UserId = prtx_UpdatedBy
          FROM PRTransaction
         WHERE (prtx_CompanyId = @TrxCompanyKeyId or prtx_PersonId = @TrxPersonKeyId)
          AND prtx_Status = 'O'
          AND prtx_Deleted IS NULL
     ORDER BY ISNULL(prtx_PersonId, 0) DESC;

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Address ' + convert(varchar,@AdLi_AddressLinkId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

		DECLARE @AddressID int, @PersonID int, @Index int, @Count int
	    DECLARE @Address1 varchar(40),@Address2 varchar(40),@Address3 varchar(40),@Address4 varchar(40), @County varchar(30)
		DECLARE @PostCode varchar(10),@Description varchar(100),@CityStateCountryShort varchar(200),@PRPublish varchar(1)
        DECLARE @PRDefaultMailing nchar(1), @PRDefaultTax nchar(1), @Type varchar(100)

		SELECT @AddressID = addr_AddressId,
               @CompanyID = adli_CompanyID,
               @PersonID = adli_PersonID,
               @Address1 = addr_Address1,
			   @Address2 = addr_Address2,
			   @Address3 = addr_Address3,
               @Address4 = addr_Address4,
			   @PostCode = addr_PostCode,
			   @Description = addr_PRDescription,
               @CityStateCountryShort = CityStateCountryShort,
               @PRPublish = ISNULL(addr_PRPublish, 'N'),
               @Type = adli_Type,
               @PRDefaultMailing = AdLi_PRDefaultMailing,
               @PRDefaultTax = AdLi_PRDefaultTax,
               @County = addr_PRCounty
          FROM vPRAddress
         WHERE addr_AddressId = @AdLi_AddressId;


		IF (@PersonID IS NULL) BEGIN
			SET @NewValue = dbo.ufn_GetCustomCaptionValue('adli_TypeCompany', @Type, 'en-us')
		END ELSE BEGIN
			SET @NewValue = dbo.ufn_GetCustomCaptionValue('adli_TypePerson', @Type, 'en-us')
		END
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'adli_Type', NULL, @NewValue, @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'addr_Address1', NULL, @Address1,  @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'addr_Address2', NULL, @Address2,  @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'addr_Address3', NULL, @Address3,  @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'addr_Address4', NULL, @Address4,  @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'City/State/Country', NULL, @CityStateCountryShort,  @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'addr_PostCode', NULL, @PostCode,  @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'addr_PRCounty', NULL, @County,  @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'addr_PRDescription', NULL, @Description,  @UserId, @TransactionDetailTypeId
		EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', 'addr_PRPublish', NULL, @PRPublish,  @UserId, @TransactionDetailTypeId

		IF (@PersonId IS NULL) BEGIN
			SET @NewValue = ISNULL(@PRDefaultMailing, 'N')
			SET @NewValue = @NewValue + ', ' + ISNULL(@PRDefaultTax, 'N')

			Set @Caption = 'Def Mailing, Def Tax'
			exec usp_CreateTransactionDetail @prtx_TransactionId, 'Address', 'Insert', @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
		END

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
		Close crs
		DEALLOCATE crs
    END TRY
    BEGIN CATCH
		Close crs
		DEALLOCATE crs
		exec usp_RethrowError
    END CATCH
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
    Declare @prbe_BusinessEventTypeId int
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

    SELECT @TrxKeyId = i.prbe_CompanyId, @UserId = i.prbe_UpdatedBy, @prbe_BusinessEventId = i.prbe_BusinessEventId
        FROM Inserted i
        INNER JOIN deleted d ON i.prbe_BusinessEventId = d.prbe_BusinessEventId
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
        Update (prbe_EffectiveDate) OR
        Update (prbe_CreditSheetPublish) OR
        Update (prbe_CreditSheetNote) OR
        Update (prbe_PublishedAnalysis) OR
        Update (prbe_InternalAnalysis) OR
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
        Update (prbe_DetailedType) OR
        Update (prbe_OtherDescription) )
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Business Event ' + convert(varchar,@prbe_BusinessEventId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prbe_EffectiveDate datetime, @del_prbe_EffectiveDate datetime
        Declare @ins_prbe_CreditSheetPublish nchar(1), @del_prbe_CreditSheetPublish nchar(1)
        Declare @ins_prbe_CreditSheetNote varchar(max), @del_prbe_CreditSheetNote varchar(max)
        Declare @ins_prbe_PublishedAnalysis varchar(max), @del_prbe_PublishedAnalysis varchar(max)
        Declare @ins_prbe_InternalAnalysis varchar(max), @del_prbe_InternalAnalysis varchar(max)
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
        Declare @ins_prbe_OtherDescription varchar(max), @del_prbe_OtherDescription varchar(max)
        -- For each updated field value create a transaction detail record
        SELECT
            @prbe_BusinessEventTypeId = i.prbe_BusinessEventTypeId,
            @ins_prbe_EffectiveDate = i.prbe_EffectiveDate, @del_prbe_EffectiveDate = d.prbe_EffectiveDate,
            @ins_prbe_CreditSheetPublish = i.prbe_CreditSheetPublish, @del_prbe_CreditSheetPublish = d.prbe_CreditSheetPublish,
            @ins_prbe_CreditSheetNote = i.prbe_CreditSheetNote, @del_prbe_CreditSheetNote = d.prbe_CreditSheetNote,
            @ins_prbe_PublishedAnalysis = i.prbe_PublishedAnalysis, @del_prbe_PublishedAnalysis = d.prbe_PublishedAnalysis,
            @ins_prbe_InternalAnalysis = i.prbe_InternalAnalysis, @del_prbe_InternalAnalysis = d.prbe_InternalAnalysis,
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
            @ins_prbe_DetailedType = i.prbe_DetailedType, @del_prbe_DetailedType = d.prbe_DetailedType,
            @ins_prbe_OtherDescription = i.prbe_OtherDescription, @del_prbe_OtherDescription = d.prbe_OtherDescription
        FROM Inserted i
        INNER JOIN deleted d ON i.prbe_BusinessEventId = d.prbe_BusinessEventId

        -- prbe_EffectiveDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prbe_EffectiveDate, @ins_prbe_EffectiveDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prbe_EffectiveDate IS NOT NULL AND convert(varchar,@del_prbe_EffectiveDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_prbe_EffectiveDate)
            IF (@ins_prbe_EffectiveDate IS NOT NULL AND convert(varchar,@ins_prbe_EffectiveDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_prbe_EffectiveDate)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_EffectiveDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_CreditSheetPublish
        IF  (  Update(prbe_CreditSheetPublish))
        BEGIN
            SET @OldValue =  @del_prbe_CreditSheetPublish
            SET @NewValue =  @ins_prbe_CreditSheetPublish
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_CreditSheetPublish', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_CreditSheetNote
        IF  (  Update(prbe_CreditSheetNote))
        BEGIN
            SET @OldValue =  @del_prbe_CreditSheetNote
            SET @NewValue =  @ins_prbe_CreditSheetNote
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_CreditSheetNote', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_PublishedAnalysis
        IF  (  Update(prbe_PublishedAnalysis))
        BEGIN
            SET @OldValue =  @del_prbe_PublishedAnalysis
            SET @NewValue =  @ins_prbe_PublishedAnalysis
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_PublishedAnalysis', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_InternalAnalysis
        IF  (  Update(prbe_InternalAnalysis))
        BEGIN
            SET @OldValue =  @del_prbe_InternalAnalysis
            SET @NewValue =  @ins_prbe_InternalAnalysis
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_InternalAnalysis', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_PublishUntilDate
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prbe_PublishUntilDate, @ins_prbe_PublishUntilDate) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prbe_PublishUntilDate IS NOT NULL AND convert(varchar,@del_prbe_PublishUntilDate,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_prbe_PublishUntilDate)
            IF (@ins_prbe_PublishUntilDate IS NOT NULL AND convert(varchar,@ins_prbe_PublishUntilDate,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_prbe_PublishUntilDate)
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
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prbe_DisasterImpact' AND capt_code = @ins_prbe_DisasterImpact
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prbe_DisasterImpact)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
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
            SET @OldValue =  convert(varchar(max), @del_prbe_Amount)
            SET @NewValue =  convert(varchar(max), @ins_prbe_Amount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_Amount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_AssetAmount
        IF  (  Update(prbe_AssetAmount))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prbe_AssetAmount)
            SET @NewValue =  convert(varchar(max), @ins_prbe_AssetAmount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_AssetAmount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_LiabilityAmount
        IF  (  Update(prbe_LiabilityAmount))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prbe_LiabilityAmount)
            SET @NewValue =  convert(varchar(max), @ins_prbe_LiabilityAmount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_LiabilityAmount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_IndividualBuyerId
        IF  (  Update(prbe_IndividualBuyerId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_firstname + ' ' + pers_lastname FROM person
                WHERE pers_PersonId = @ins_prbe_IndividualBuyerId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_prbe_IndividualBuyerId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_firstname + ' ' + pers_lastname FROM person
                WHERE pers_PersonId = @del_prbe_IndividualBuyerId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_prbe_IndividualBuyerId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_IndividualBuyerId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_IndividualSellerId
        IF  (  Update(prbe_IndividualSellerId))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_firstname + ' ' + pers_lastname FROM person WITH (NOLOCK)
                WHERE pers_PersonId = @ins_prbe_IndividualSellerId
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_prbe_IndividualSellerId))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = pers_firstname + ' ' + pers_lastname FROM person WITH (NOLOCK)
                WHERE pers_PersonId = @del_prbe_IndividualSellerId
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_prbe_IndividualSellerId))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_IndividualSellerId', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_RelatedCompany1Id
        IF  (  Update(prbe_RelatedCompany1Id))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM company WITH (NOLOCK)
                WHERE comp_companyid = @ins_prbe_RelatedCompany1Id
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_prbe_RelatedCompany1Id))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM company WITH (NOLOCK)
                WHERE comp_companyid = @del_prbe_RelatedCompany1Id
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_prbe_RelatedCompany1Id))

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_RelatedCompany1Id', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_RelatedCompany2Id
        IF  (  Update(prbe_RelatedCompany2Id))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM company WITH (NOLOCK)
                WHERE comp_companyid = @ins_prbe_RelatedCompany2Id
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_prbe_RelatedCompany2Id))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM company WITH (NOLOCK)


                WHERE comp_companyid = @del_prbe_RelatedCompany2Id
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_prbe_RelatedCompany2Id))

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
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prbe_USBankruptcyEntity' AND capt_code = @ins_prbe_USBankruptcyEntity
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prbe_USBankruptcyEntity)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prbe_USBankruptcyEntity' AND capt_code = @del_prbe_USBankruptcyEntity
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prbe_USBankruptcyEntity)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_USBankruptcyEntity', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_USBankruptcyCourt
        IF  (  Update(prbe_USBankruptcyCourt))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prbe_USBankruptcyCourt' AND capt_code = @ins_prbe_USBankruptcyCourt
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prbe_USBankruptcyCourt)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prbe_USBankruptcyCourt' AND capt_code = @del_prbe_USBankruptcyCourt
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prbe_USBankruptcyCourt)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_USBankruptcyCourt', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_StateId
        IF  (  Update(prbe_StateId))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prbe_StateId)
            SET @NewValue =  convert(varchar(max), @ins_prbe_StateId)
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
            SET @OldValue =  convert(varchar(max), @del_prbe_PercentSold)
            SET @NewValue =  convert(varchar(max), @ins_prbe_PercentSold)
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
            SET @OldValue =  convert(varchar(max), @del_prbe_NumberSellers)
            SET @NewValue =  convert(varchar(max), @ins_prbe_NumberSellers)
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
                SET @OldValue =  convert(varchar(max), @del_prbe_BusinessOperateUntil)
            IF (@ins_prbe_BusinessOperateUntil IS NOT NULL AND convert(varchar,@ins_prbe_BusinessOperateUntil,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_prbe_BusinessOperateUntil)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_BusinessOperateUntil', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_IndividualOperateUntil
        IF  (  dbo.ufn_IsAccpacDateUpdated( @del_prbe_IndividualOperateUntil, @ins_prbe_IndividualOperateUntil) = 1)
        BEGIN
            SET @OldValue = ''
            SET @NewValue = ''
            IF (@del_prbe_IndividualOperateUntil IS NOT NULL AND convert(varchar,@del_prbe_IndividualOperateUntil,101) != '12/30/1899') 
                SET @OldValue =  convert(varchar(max), @del_prbe_IndividualOperateUntil)
            IF (@ins_prbe_IndividualOperateUntil IS NOT NULL AND convert(varchar,@ins_prbe_IndividualOperateUntil,101) != '12/30/1899') 
                SET @NewValue =  convert(varchar(max), @ins_prbe_IndividualOperateUntil)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_IndividualOperateUntil', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_DisplayedEffectiveDate
        IF  (  Update(prbe_DisplayedEffectiveDate))
        BEGIN
            SET @OldValue =  @del_prbe_DisplayedEffectiveDate
            SET @NewValue =  @ins_prbe_DisplayedEffectiveDate
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_DisplayedEffectiveDate', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_DetailedType
        IF  (  Update(prbe_DetailedType))
        BEGIN
			DECLARE @Capt_Family varchar(40);
			SET @Capt_Family = CASE @prbe_BusinessEventTypeId 
				WHEN '1' THEN 'prbe_AcquisitionType'
				WHEN '2' THEN 'prbe_AcquisitionType'
				WHEN '5' THEN 'prbe_USBankruptcyType'
				WHEN '6' THEN 'prbe_CanBankruptcyType'
				WHEN '7' THEN 'prbe_BusinessClosureType'
				WHEN '8' THEN 'prbe_NewEntityType'
				WHEN '9' THEN 'prbe_NewEntityType'
				WHEN '10' THEN 'prbe_SaleType'
                WHEN '11' THEN 'prbe_AcquisitionType'
				WHEN '12' THEN 'prbe_DRCType'
				WHEN '13' THEN 'prbe_ExtensionType'
				WHEN '19' THEN 'prbe_AcquisitionType'
				WHEN '23' THEN 'prbe_DisasterType'
				WHEN '27' THEN 'prbe_OtherPACAType'
				WHEN '28' THEN 'prbe_PACASuspensionType'
			END

			SELECT @OldValue = Capt_US FROM custom_captions WITH (NOLOCK) where Capt_family = @Capt_Family AND Capt_Code = @del_prbe_DetailedType;
			SELECT @NewValue = Capt_US FROM custom_captions WITH (NOLOCK) where Capt_family = @Capt_Family AND Capt_Code = @ins_prbe_DetailedType;

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_DetailedType', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prbe_OtherDescription
        IF  (  Update(prbe_OtherDescription))
        BEGIN
            SET @OldValue =  @del_prbe_OtherDescription
            SET @NewValue =  @ins_prbe_OtherDescription
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Business Event', @Action, 'prbe_OtherDescription', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

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


/* ************************************************************
 *
 * Business Events no longer require open PIKS transactions
 * to be edited. 
 *
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRBusinessEvent_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRBusinessEvent_insdel]
GO



/* ************************************************************
 * Name:   dbo.trg_Person_Link_ioins
 * 
 * Table:  Person_Link
 * Action: INSERT
 * 
  * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Person_Link_ioins]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Person_Link_ioins]
GO

CREATE TRIGGER dbo.trg_Person_Link_ioins
ON Person_Link
FOR INSERT AS
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
    Declare @Caption varchar(500)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'

    SET @Action = 'Insert'

    SELECT @TrxKeyId = i.peli_PersonId, @UserId = i.peli_UpdatedBy, @peli_PersonLinkId = i.peli_PersonLinkId
     FROM Inserted i;

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
           @UserId = prtx_UpdatedBy
    FROM PRTransaction
    WHERE prtx_PersonId = @TrxKeyId
        AND prtx_Status = 'O'
        AND prtx_Deleted IS NULL;

    IF (
        Update (PeLi_CompanyID) OR
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
        Update (peli_PRRole) OR
        Update (peli_PROwnershipRole) OR
        Update (peli_PRReceivesBBScoreReport) OR
        Update (peli_PRWhenVisited))
    BEGIN

        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  History ' + convert(varchar,@peli_PersonLinkId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_PeLi_CompanyID int
        Declare @ins_peli_PRTitleCode nvarchar(40)
        Declare @ins_peli_PRDLTitle nvarchar(30)
        Declare @ins_peli_PRTitle nvarchar(30)
        Declare @ins_peli_PRResponsibilities nvarchar(75)
        Declare @ins_peli_PRPctOwned numeric
        Declare @ins_peli_PREBBPublish nchar(1)
        Declare @ins_peli_PRBRPublish nchar(1)
        Declare @ins_peli_PRExitReason nvarchar(75)
        Declare @ins_peli_PRRatingLine nvarchar(50)
        Declare @ins_peli_PRStartDate nvarchar(25)
        Declare @ins_peli_PREndDate nvarchar(25)
        Declare @ins_peli_PRStatus nvarchar(40)
        Declare @ins_peli_PRRole nvarchar(255)
        Declare @ins_peli_PROwnershipRole nvarchar(40)
        Declare @ins_peli_PRReceivesBBScoreReport nchar(1)
        Declare @ins_peli_PRWhenVisited nvarchar(50)


        -- For each updated field value create a transaction detail record
        SELECT
            @ins_PeLi_CompanyID = i.PeLi_CompanyID,
            @ins_peli_PRTitleCode = i.peli_PRTitleCode,
            @ins_peli_PRDLTitle = i.peli_PRDLTitle, 
            @ins_peli_PRTitle = i.peli_PRTitle, 
            @ins_peli_PRResponsibilities = i.peli_PRResponsibilities,
            @ins_peli_PRPctOwned = i.peli_PRPctOwned, 
            @ins_peli_PREBBPublish = i.peli_PREBBPublish, 
            @ins_peli_PRBRPublish = i.peli_PRBRPublish, 
            @ins_peli_PRExitReason = i.peli_PRExitReason, 
            @ins_peli_PRRatingLine = i.peli_PRRatingLine, 
            @ins_peli_PRStartDate = i.peli_PRStartDate, 
            @ins_peli_PREndDate = i.peli_PREndDate, 
            @ins_peli_PRStatus = i.peli_PRStatus, 
            @ins_peli_PRRole = i.peli_PRRole, 
            @ins_peli_PROwnershipRole = i.peli_PROwnershipRole, 
            @ins_peli_PRReceivesBBScoreReport = i.peli_PRReceivesBBScoreReport, 
            @ins_peli_PRWhenVisited = i.peli_PRWhenVisited
        FROM Inserted i;


		DECLARE @ColumnPrefix varchar(20)
		SET @ColumnPrefix = 'BB #' + CAST(@ins_PeLi_CompanyID AS varchar(10)) + ' - ';

        -- PeLi_CompanyID
        IF  (  Update(PeLi_CompanyID))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM Company WITH (NOLOCK) WHERE comp_companyid = @ins_PeLi_CompanyID
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(20), @ins_PeLi_CompanyID))

			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('PeLi_CompanyID')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRTitleCode
        IF  (  Update(peli_PRTitleCode))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='Pers_TitleCode' AND capt_code = @ins_peli_PRTitleCode
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_peli_PRTitleCode)

			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRTitleCode')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRDLTitle
        IF  (  Update(peli_PRDLTitle))
        BEGIN
            SET @NewValue =  @ins_peli_PRDLTitle
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRDLTitle')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRTitle
        IF  (  Update(peli_PRTitle))
        BEGIN
            SET @NewValue =  @ins_peli_PRTitle
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRTitle')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRResponsibilities
        IF  (  Update(peli_PRResponsibilities))
        BEGIN
            SET @NewValue =  @ins_peli_PRResponsibilities
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRResponsibilities')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRPctOwned
        IF  (  Update(peli_PRPctOwned))
        BEGIN
            SET @NewValue =  convert(varchar(max), @ins_peli_PRPctOwned)
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRPctOwned')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PREBBPublish
        IF  (  Update(peli_PREBBPublish))
        BEGIN
            SET @NewValue =  @ins_peli_PREBBPublish
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PREBBPublish')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRBRPublish
        IF  (  Update(peli_PRBRPublish))
        BEGIN
            SET @NewValue =  @ins_peli_PRBRPublish
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRBRPublish')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRExitReason
        IF  (  Update(peli_PRExitReason))
        BEGIN
            SET @NewValue =  @ins_peli_PRExitReason
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRExitReason')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRRatingLine
        IF  (  Update(peli_PRRatingLine))
        BEGIN
            SET @NewValue =  @ins_peli_PRRatingLine
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRRatingLine')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRStartDate
        IF  (  Update(peli_PRStartDate))
        BEGIN
            SET @NewValue =  @ins_peli_PRStartDate
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRStartDate')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PREndDate
        IF  (  Update(peli_PREndDate))
        BEGIN
            SET @NewValue =  @ins_peli_PREndDate
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PREndDate')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRStatus
        IF  (  Update(peli_PRStatus))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='peli_PRStatus' AND capt_code = @ins_peli_PRStatus
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_peli_PRStatus)

			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRStatus')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRRole
        IF  (  Update(peli_PRRole))
        BEGIN
            SET @NewValue =  @ins_peli_PRRole
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRRole')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PROwnershipRole
        IF  (  Update(peli_PROwnershipRole))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='peli_PROwnershipRole' AND capt_code = @ins_peli_PROwnershipRole
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_peli_PROwnershipRole)

			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PROwnershipRole')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRReceivesBBScoreReport
        IF  (  Update(peli_PRReceivesBBScoreReport))
        BEGIN
            SET @NewValue =  @ins_peli_PRReceivesBBScoreReport

			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRReceivesBBScoreReport')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRWhenVisited
        IF  (  Update(peli_PRWhenVisited))
        BEGIN
            SET @NewValue =  @ins_peli_PRWhenVisited
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRWhenVisited')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, NULL, @NewValue, @UserId, @TransactionDetailTypeId
        END

    END
END
GO



/* ************************************************************
 * Name:   dbo.trg_Person_Link_iodel
 * 
 * Table:  Person_Link
 * Action: DELETE
 * 
  * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Person_Link_iodel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	drop trigger [dbo].[trg_Person_Link_iodel]
GO

CREATE TRIGGER dbo.trg_Person_Link_iodel
ON Person_Link
FOR DELETE AS
BEGIN
    SET NOCOUNT ON
    Declare @Err int
    SET @Err = 0
    Declare @prtx_TransactionId int
    Declare @Msg varchar(255)

    Declare @TrxKeyId int
    Declare @peli_PersonLinkId int
    Declare @UserId int
    Declare @PersonId int
    Declare @Caption varchar(500)
    Declare @OldValue varchar(max)
    Declare @Action varchar(200)
    Declare @OldValueTemp varchar(3000)

    SET @Action = 'Delete'
    SELECT @TrxKeyId = d.peli_PersonId, 
           @UserId = d.peli_UpdatedBy, 
           @peli_PersonLinkId = d.peli_PersonLinkId
      FROM deleted d;

    -- There should always be a transaction started
    -- If we cannot find it; this action should fail
    SET @prtx_TransactionId = NULL
    SELECT @prtx_TransactionId = prtx_TransactionId,
           @UserId = prtx_UpdatedBy
      FROM PRTransaction
     WHERE prtx_PersonId = @TrxKeyId
           AND prtx_Status = 'O'
           AND prtx_Deleted IS NULL;

    IF (@prtx_TransactionId IS NULL)
    BEGIN
        SET @Msg = 'Changes Failed.  History ' + convert(varchar,@peli_PersonLinkId) + ' values can only be changed if a transaction is open.'
        ROLLBACK
        RAISERROR (@Msg, 16, 1)
        Return
    END

    Declare @del_PeLi_CompanyID int
    Declare @del_peli_PRTitleCode nvarchar(40)
    Declare @del_peli_PRDLTitle nvarchar(30)
    Declare @del_peli_PRTitle nvarchar(30)
    Declare @del_peli_PRResponsibilities nvarchar(75)
    Declare @del_peli_PRPctOwned numeric
    Declare @del_peli_PREBBPublish nchar(1)
    Declare @del_peli_PRBRPublish nchar(1)
    Declare @del_peli_PRExitReason nvarchar(75)
    Declare @del_peli_PRRatingLine nvarchar(50)
    Declare @del_peli_PRStartDate nvarchar(25)
    Declare @del_peli_PREndDate nvarchar(25)
    Declare @del_peli_PRStatus nvarchar(40)
    Declare @del_peli_PRRole nvarchar(255)
    Declare @del_peli_PROwnershipRole nvarchar(40)
    Declare @del_peli_PRReceivesBBScoreReport nchar(1)
    Declare @del_peli_PRWhenVisited nvarchar(50)

    -- For each updated field value create a transaction detail record
    SELECT
        @del_PeLi_CompanyID = d.PeLi_CompanyID,
        @del_peli_PRTitleCode = d.peli_PRTitleCode,
        @del_peli_PRDLTitle = d.peli_PRDLTitle, 
        @del_peli_PRTitle = d.peli_PRTitle, 
        @del_peli_PRResponsibilities = d.peli_PRResponsibilities,
        @del_peli_PRPctOwned = d.peli_PRPctOwned, 
        @del_peli_PREBBPublish = d.peli_PREBBPublish, 
        @del_peli_PRBRPublish = d.peli_PRBRPublish, 
        @del_peli_PRExitReason = d.peli_PRExitReason, 
        @del_peli_PRRatingLine = d.peli_PRRatingLine, 
        @del_peli_PRStartDate = d.peli_PRStartDate, 
        @del_peli_PREndDate = d.peli_PREndDate, 
        @del_peli_PRStatus = d.peli_PRStatus, 
        @del_peli_PRRole = d.peli_PRRole, 
        @del_peli_PROwnershipRole = d.peli_PROwnershipRole, 
        @del_peli_PRReceivesBBScoreReport = d.peli_PRReceivesBBScoreReport, 
        @del_peli_PRWhenVisited = d.peli_PRWhenVisited 
    FROM Deleted d;

		DECLARE @ColumnPrefix varchar(20)
		SET @ColumnPrefix = 'BB #' + CAST(@del_PeLi_CompanyID AS varchar(10)) + ' - ';

        -- PeLi_CompanyID
        SET @OldValueTemp = NULL
        SELECT @OldValueTemp = comp_name FROM Company WITH (NOLOCK) WHERE comp_companyid = @del_PeLi_CompanyID
        SET @OldValue = COALESCE(@OldValueTemp,  convert(varchar(20), @del_PeLi_CompanyID))
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_CompanyID')
        EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

		-- peli_PRTitleCode
        SET @OldValueTemp = NULL
        SELECT @OldValueTemp = capt_us FROM custom_captions WITH (NOLOCK) WHERE capt_family='Pers_TitleCode' AND capt_code = @del_peli_PRTitleCode
        SET @OldValue = COALESCE(@OldValueTemp,  @del_peli_PRTitleCode)
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRTitleCode')
        EXEC usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRDLTitle
        SET @OldValue =  @del_peli_PRDLTitle
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRDLTitle')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRTitle
        SET @OldValue =  @del_peli_PRTitle
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRTitle')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRResponsibilities
        SET @OldValue =  @del_peli_PRResponsibilities
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRResponsibilities')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRPctOwned
        SET @OldValue =  convert(varchar(max), @del_peli_PRPctOwned)
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRPctOwned')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PREBBPublish
        SET @OldValue =  @del_peli_PREBBPublish
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PREBBPublish')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRBRPublish
        SET @OldValue =  @del_peli_PRBRPublish
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRBRPublish')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRExitReason
        SET @OldValue =  @del_peli_PRExitReason
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRExitReason')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRRatingLine
        SET @OldValue =  @del_peli_PRRatingLine
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRRatingLine')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRStartDate
        SET @OldValue =  @del_peli_PRStartDate
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRStartDate')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PREndDate
        SET @OldValue =  @del_peli_PREndDate
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PREndDate')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRStatus
        SET @OldValueTemp = NULL
        SELECT @OldValueTemp = capt_us FROM custom_captions WITH (NOLOCK) WHERE capt_family='peli_PRStatus' AND capt_code = @del_peli_PRStatus
        SET @OldValue = COALESCE(@OldValueTemp,  @del_peli_PRStatus)
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRStatus')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRRole
        SET @OldValue =  @del_peli_PRRole
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRRole')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PROwnershipRole
        SET @OldValueTemp = NULL
        SELECT @OldValueTemp = capt_us FROM custom_captions WITH (NOLOCK) WHERE capt_family='peli_PROwnershipRole' AND capt_code = @del_peli_PROwnershipRole
        SET @OldValue = COALESCE(@OldValueTemp,  @del_peli_PROwnershipRole)

		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PROwnershipRole')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRReceivesBBScoreReport
        SET @OldValue =  @del_peli_PRReceivesBBScoreReport
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRReceivesBBScoreReport')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId

        -- peli_PRWhenVisited
        SET @OldValue =  @del_peli_PRWhenVisited
		SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRWhenVisited')
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, NULL, @UserId
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
CREATE OR ALTER TRIGGER dbo.trg_Person_Link_ioupd
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
    Declare @Caption varchar(500)
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
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
        Update (PeLi_CompanyID) OR
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
        Update (peli_PRRole) OR
        Update (peli_PROwnershipRole) OR
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

        Declare @ins_PeLi_CompanyID int, @del_PeLi_CompanyID int
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
        Declare @ins_peli_PRRole nvarchar(255), @del_peli_PRRole nvarchar(255)
        Declare @ins_peli_PROwnershipRole nvarchar(40), @del_peli_PROwnershipRole nvarchar(40)
        Declare @ins_peli_PRReceivesBBScoreReport nchar(1), @del_peli_PRReceivesBBScoreReport nchar(1)
        Declare @ins_peli_PRWhenVisited nvarchar(50), @del_peli_PRWhenVisited nvarchar(50) 

        -- For each updated field value create a transaction detail record
        SELECT
            @ins_PeLi_CompanyID = i.PeLi_CompanyID, @del_PeLi_CompanyID = d.PeLi_CompanyID,
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
            @ins_peli_PRRole = i.peli_PRRole, @del_peli_PRRole = d.peli_PRRole,
            @ins_peli_PROwnershipRole = i.peli_PROwnershipRole, @del_peli_PROwnershipRole = d.peli_PROwnershipRole,
            @ins_peli_PRReceivesBBScoreReport = i.peli_PRReceivesBBScoreReport, @del_peli_PRReceivesBBScoreReport = d.peli_PRReceivesBBScoreReport,
            @ins_peli_PRWhenVisited = i.peli_PRWhenVisited, @del_peli_PRWhenVisited = d.peli_PRWhenVisited
        FROM Inserted i
        INNER JOIN deleted d ON i.peli_PersonLinkId = d.peli_PersonLinkId

		DECLARE @ColumnPrefix varchar(20)
		SET @ColumnPrefix = 'BB #' + CAST(@ins_PeLi_CompanyID AS varchar(10)) + ' - ';

        -- PeLi_CompanyID
        IF  (  Update(PeLi_CompanyID))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM Company
                WHERE comp_companyid = @ins_PeLi_CompanyID
            SET @NewValue = COALESCE(@NewValueTemp,  convert(varchar(max), @ins_PeLi_CompanyID))

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = comp_name FROM Company
                WHERE comp_companyid = @del_PeLi_CompanyID
            SET @OldValue = COALESCE(@NewValueTemp,  convert(varchar(max), @del_PeLi_CompanyID))

			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('PeLi_CompanyID')	
	        exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRTitleCode
        IF  (  Update(peli_PRTitleCode))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='Pers_TitleCode' AND capt_code = @ins_peli_PRTitleCode
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_peli_PRTitleCode)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='Pers_TitleCode' AND capt_code = @del_peli_PRTitleCode
            SET @OldValue = COALESCE(@NewValueTemp,  @del_peli_PRTitleCode)

			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRTitleCode')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRDLTitle
        IF  (  Update(peli_PRDLTitle))
        BEGIN
            SET @OldValue =  @del_peli_PRDLTitle
            SET @NewValue =  @ins_peli_PRDLTitle
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRDLTitle')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRTitle
        IF  (  Update(peli_PRTitle))
        BEGIN
            SET @OldValue =  @del_peli_PRTitle
            SET @NewValue =  @ins_peli_PRTitle
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRTitle')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRResponsibilities
        IF  (  Update(peli_PRResponsibilities))
        BEGIN
            SET @OldValue =  @del_peli_PRResponsibilities
            SET @NewValue =  @ins_peli_PRResponsibilities
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRResponsibilities')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRPctOwned
        IF  (  Update(peli_PRPctOwned))
        BEGIN
            SET @OldValue =  convert(varchar(100), ISNULL(@del_peli_PRPctOwned, 0))
            SET @NewValue =  convert(varchar(100), ISNULL(@ins_peli_PRPctOwned, 0))
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRPctOwned')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PREBBPublish
        IF  (  Update(peli_PREBBPublish))
        BEGIN
            SET @OldValue =  @del_peli_PREBBPublish
            SET @NewValue =  @ins_peli_PREBBPublish
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PREBBPublish')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRBRPublish
        IF  (  Update(peli_PRBRPublish))
        BEGIN
            SET @OldValue =  @del_peli_PRBRPublish
            SET @NewValue =  @ins_peli_PRBRPublish
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRBRPublish')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRExitReason
        IF  (  Update(peli_PRExitReason))
        BEGIN
            SET @OldValue =  @del_peli_PRExitReason
            SET @NewValue =  @ins_peli_PRExitReason
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRExitReason')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRRatingLine
        IF  (  Update(peli_PRRatingLine))
        BEGIN
            SET @OldValue =  @del_peli_PRRatingLine
            SET @NewValue =  @ins_peli_PRRatingLine
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRRatingLine')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRStartDate
        IF  (  Update(peli_PRStartDate))
        BEGIN
            SET @OldValue =  @del_peli_PRStartDate
            SET @NewValue =  @ins_peli_PRStartDate
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRStartDate')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PREndDate
        IF  (  Update(peli_PREndDate))
        BEGIN
            SET @OldValue =  @del_peli_PREndDate
            SET @NewValue =  @ins_peli_PREndDate
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PREndDate')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRStatus
        IF  (  Update(peli_PRStatus))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='peli_PRStatus' AND capt_code = @ins_peli_PRStatus
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_peli_PRStatus)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='peli_PRStatus' AND capt_code = @del_peli_PRStatus
            SET @OldValue = COALESCE(@NewValueTemp,  @del_peli_PRStatus)

			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRStatus')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRRole
        IF  (  Update(peli_PRRole))
        BEGIN
            SET @OldValue =  @del_peli_PRRole
            SET @NewValue =  @ins_peli_PRRole
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRRole')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PROwnershipRole
        IF  (  Update(peli_PROwnershipRole))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='peli_PROwnershipRole' AND capt_code = @ins_peli_PROwnershipRole
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_peli_PROwnershipRole)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='peli_PROwnershipRole' AND capt_code = @del_peli_PROwnershipRole
            SET @OldValue = COALESCE(@NewValueTemp,  @del_peli_PROwnershipRole)

			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PROwnershipRole')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRReceivesBBScoreReport
        IF  (  Update(peli_PRReceivesBBScoreReport))
        BEGIN
            SET @OldValue =  @del_peli_PRReceivesBBScoreReport
            SET @NewValue =  @ins_peli_PRReceivesBBScoreReport
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRReceivesBBScoreReport')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- peli_PRWhenVisited
        IF  (  Update(peli_PRWhenVisited))
        BEGIN
            SET @OldValue =  @del_peli_PRWhenVisited
            SET @NewValue =  @ins_peli_PRWhenVisited
			SET @Caption = @ColumnPrefix + dbo.ufn_GetFieldCaption('peli_PRWhenVisited')
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'History', @Action, @Caption, @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

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
        Person_Link.peli_PRRole=i.peli_PRRole, 
        Person_Link.peli_PROwnershipRole=i.peli_PROwnershipRole, 
        Person_Link.peli_WebStatus=i.peli_WebStatus, 
        Person_Link.peli_WebPassword=i.peli_WebPassword, 
        Person_Link.peli_PRAUSReceiveMethod=i.peli_PRAUSReceiveMethod, 
        Person_Link.peli_PRAUSChangePreference=i.peli_PRAUSChangePreference, 
        Person_Link.peli_PRReceivesBBScoreReport=i.peli_PRReceivesBBScoreReport, 
        Person_Link.peli_PRWhenVisited=i.peli_PRWhenVisited, 
        Person_Link.peli_PRSubmitTES=i.peli_PRSubmitTES, 
        Person_Link.peli_PRUpdateCL=i.peli_PRUpdateCL, 
        Person_Link.peli_PRUseServiceUnits=i.peli_PRUseServiceUnits, 
        Person_Link.peli_PRUseSpecialServices=i.peli_PRUseSpecialServices, 
        Person_Link.peli_PRConvertToBBOS=i.peli_PRConvertToBBOS, 
        Person_Link.peli_PRReceivesTrainingEmail=i.peli_PRReceivesTrainingEmail, 
        Person_Link.peli_PRReceivesPromoEmail=i.peli_PRReceivesPromoEmail, 
        Person_Link.peli_PRWillSubmitARAging=i.peli_PRWillSubmitARAging, 
        Person_Link.peli_PRReceivesCreditSheetReport=i.peli_PRReceivesCreditSheetReport, 
        Person_Link.peli_PREditListing=i.peli_PREditListing,
		Person_Link.peli_PRReceiveBRSurvey=i.peli_PRReceiveBRSurvey,
		Person_Link.peli_PRCSReceiveMethod=i.peli_PRCSReceiveMethod,
		Person_Link.peli_PRCSSortOption=i.peli_PRCSSortOption,
		Person_Link.peli_PRSequence=i.peli_PRSequence,
		Person_Link.peli_PRAlertEmail=i.peli_PRAlertEmail,
		Person_Link.peli_PRCanViewBusinessValuations=i.peli_PRCanViewBusinessValuations
        FROM inserted i 
          INNER JOIN Person_Link ON i.peli_PersonLinkId=Person_Link.peli_PersonLinkId
    END
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
INSTEAD OF INSERT, UPDATE AS
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
    Declare @OldValue varchar(max)
    Declare @NewValue varchar(max)
    Declare @Action varchar(200)
    Declare @NewValueTemp varchar(3000)

    -- get the Accpac ID value for this entity so we can get the next available Id
    select @TransactionDetailTypeId = Bord_TableId from custom_tables where Bord_Caption = 'PRTransactionDetail'


	SET @Action = 'Update'
	
	DECLARE @DelCount int
	SELECT @DelCount = COUNT(1) FROM deleted;
	IF (@DelCount = 0) BEGIN
		SET @Action = 'Insert'
	END



    SELECT @TrxKeyId = i.prcp_CompanyID, @UserId = i.prcp_UpdatedBy, @prcp_CompanyProfileId = i.prcp_CompanyProfileId
        FROM Inserted i
        LEFT OUTER JOIN deleted d ON i.prcp_CompanyProfileId = d.prcp_CompanyProfileId

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
        Update (prcp_SrcBuyOfficeWholesalePct) OR
        Update (prcp_SrcBuyStockingWholesalePct) OR
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
        Update (prcp_TrkrLiabilityCarrier) OR
        Update (prcp_TrkrCargoAmount) OR
        Update (prcp_TrkrCargoCarrier) OR
        Update (prcp_StorageWarehouses) OR
        Update (prcp_StorageSF) OR
        Update (prcp_StorageCF) OR
        Update (prcp_StorageBushel) OR
        Update (prcp_StorageCarlots) OR
        Update (prcp_ColdStorage) OR
        Update (prcp_ColdStorageLeased) OR
        Update (prcp_RipeningStorage) OR
        Update (prcp_HumidityStorage) OR
        Update (prcp_AtmosphereStorage) OR
        Update (prcp_Organic) OR
        Update (prcp_FoodSafetyCertified) OR
        Update (prcp_SellFoodWholesaler) OR
        Update (prcp_SellRetailGrocery) OR
        Update (prcp_SellInstitutions) OR
        Update (prcp_SellRestaurants) OR
        Update (prcp_SellMilitary) OR
        Update (prcp_SellDistributors) OR
        Update (prcp_TrkBkrCollectsFreightPct) OR
        Update (prcp_TrkBkrPaymentFreightPct) OR
        Update (prcp_TrkBkrCollectsFrom) OR
        Update (prcp_TrkBkrResponsibleForPaymentOfClaims) OR
        Update (prcp_BkrCollectRemitForShipper) OR
        Update (prcp_SrcTakePhysicalPossessionPct) OR
        Update (prcp_SellShippingSeason) OR
        Update (prcp_TrnBkrArrangesTransportation) OR
        Update (prcp_TrnBkrAdvPaymentsToCarrier) OR
        Update (prcp_TrnBkrCollectsFrom) OR
        Update (prcp_TrnLogAdvPaymentsToCarrier) OR
        Update (prcp_TrnLogCollectsFrom) OR
        Update (prcp_TrnLogResponsibleForPaymentOfClaims) OR
        Update (prcp_FrtLiableForPaymentToCarrier) OR
        Update (prcp_SellCoOpPct) OR
        Update (prcp_SellRetailYardPct) OR
        Update (prcp_SellOtherPct) OR
        Update (prcp_SellHomeCenterPct) OR
        Update (prcp_SellSecManPct) OR
        Update (prcp_SellStockingWholesalePct) OR
        Update (prcp_SellOfficeWholesalePct) OR
        Update (prcp_SellProDealerPct) OR
        Update (prcp_SellWholesalePct) OR
        Update (prcp_SrcBuyMillsPct) OR
        Update (prcp_SrcBuyOtherPct) OR
        Update (prcp_SrcBuySecManPct) OR
        Update (prcp_VolumeBoardFeetPerYear) OR
        Update (prcp_VolumeTruckLoadsPerYear) OR
        Update (prcp_VolumeCarLoadsPerYear) OR
        Update (prcp_StorageCoveredSF) OR
        Update (prcp_StorageUncoveredSF) OR
        Update (prcp_RailServiceProvider1) OR
        Update (prcp_RailServiceProvider2) OR
        Update (prcp_SalvageDistressedProduce) OR
        Update (prcp_StorageOwnLease) OR
        Update (prcp_SellBuyOthersPct)  OR
		Update (prcp_GrowsOwnProducePct))
    BEGIN
        IF (@prtx_TransactionId IS NULL)
        BEGIN
            SET @Msg = 'Changes Failed.  Company Profile ' + convert(varchar,@prcp_CompanyProfileId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

        Declare @ins_prcp_CorporateStructure nvarchar(40), @del_prcp_CorporateStructure nvarchar(40)
        Declare @ins_prcp_Volume nvarchar(40), @del_prcp_Volume nvarchar(40)
        Declare @ins_prcp_FTEmployees nvarchar(40), @del_prcp_FTEmployees nvarchar(40)
        Declare @ins_prcp_PTEmployees nvarchar(40), @del_prcp_PTEmployees nvarchar(40)
        Declare @ins_prcp_SrcBuyBrokersPct int, @del_prcp_SrcBuyBrokersPct int
        Declare @ins_prcp_SrcBuyWholesalePct int, @del_prcp_SrcBuyWholesalePct int
        Declare @ins_prcp_SrcBuyShippersPct int, @del_prcp_SrcBuyShippersPct int
        Declare @ins_prcp_SrcBuyExportersPct int, @del_prcp_SrcBuyExportersPct int
        Declare @ins_prcp_SellBrokersPct int, @del_prcp_SellBrokersPct int
        Declare @ins_prcp_SrcBuyOfficeWholesalePct int, @del_prcp_SrcBuyOfficeWholesalePct int
        Declare @ins_prcp_SrcBuyStockingWholesalePct int, @del_prcp_SrcBuyStockingWholesalePct int
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
        Declare @ins_prcp_TrkrLiabilityCarrier varchar(max), @del_prcp_TrkrLiabilityCarrier varchar(max)
        Declare @ins_prcp_TrkrCargoAmount numeric, @del_prcp_TrkrCargoAmount numeric
        Declare @ins_prcp_TrkrCargoCarrier varchar(max), @del_prcp_TrkrCargoCarrier varchar(max)
        Declare @ins_prcp_StorageWarehouses int, @del_prcp_StorageWarehouses int
        Declare @ins_prcp_StorageSF nvarchar(40), @del_prcp_StorageSF nvarchar(40)
        Declare @ins_prcp_StorageCF nvarchar(40), @del_prcp_StorageCF nvarchar(40)
        Declare @ins_prcp_StorageBushel nvarchar(40), @del_prcp_StorageBushel nvarchar(40)
        Declare @ins_prcp_StorageCarlots nvarchar(40), @del_prcp_StorageCarlots nvarchar(40)
        Declare @ins_prcp_ColdStorage nchar(1), @del_prcp_ColdStorage nchar(1)
        Declare @ins_prcp_ColdStorageLeased nchar(1), @del_prcp_ColdStorageLeased nchar(1)
        Declare @ins_prcp_RipeningStorage nchar(1), @del_prcp_RipeningStorage nchar(1)
        Declare @ins_prcp_HumidityStorage nchar(1), @del_prcp_HumidityStorage nchar(1)
        Declare @ins_prcp_AtmosphereStorage nchar(1), @del_prcp_AtmosphereStorage nchar(1)
        Declare @ins_prcp_Organic nchar(1), @del_prcp_Organic nchar(1)
        Declare @ins_prcp_FoodSafetyCertified nvarchar(30), @del_prcp_FoodSafetyCertified nvarchar(30)
        Declare @ins_prcp_SellFoodWholesaler nchar(1), @del_prcp_SellFoodWholesaler nchar(1)
        Declare @ins_prcp_SellRetailGrocery nchar(1), @del_prcp_SellRetailGrocery nchar(1)
        Declare @ins_prcp_SellInstitutions nchar(1), @del_prcp_SellInstitutions nchar(1)
        Declare @ins_prcp_SellRestaurants nchar(1), @del_prcp_SellRestaurants nchar(1)
        Declare @ins_prcp_SellMilitary nchar(1), @del_prcp_SellMilitary nchar(1)
        Declare @ins_prcp_SellDistributors nchar(1), @del_prcp_SellDistributors nchar(1)
        Declare @ins_prcp_TrkBkrCollectsFreightPct int, @del_prcp_TrkBkrCollectsFreightPct int
        Declare @ins_prcp_TrkBkrPaymentFreightPct int, @del_prcp_TrkBkrPaymentFreightPct int
        Declare @ins_prcp_TrkBkrCollectsFrom nvarchar(40), @del_prcp_TrkBkrCollectsFrom nvarchar(40)
        Declare @ins_prcp_TrkBkrResponsibleForPaymentOfClaims nchar(1), @del_prcp_TrkBkrResponsibleForPaymentOfClaims nchar(1)
        Declare @ins_prcp_BkrCollectRemitForShipper nchar(1), @del_prcp_BkrCollectRemitForShipper nchar(1)
        Declare @ins_prcp_SrcTakePhysicalPossessionPct int, @del_prcp_SrcTakePhysicalPossessionPct int
        Declare @ins_prcp_SellShippingSeason nvarchar(100), @del_prcp_SellShippingSeason nvarchar(100)
        Declare @ins_prcp_TrnBkrArrangesTransportation nvarchar(40), @del_prcp_TrnBkrArrangesTransportation nvarchar(40)
        Declare @ins_prcp_TrnBkrAdvPaymentsToCarrier nchar(1), @del_prcp_TrnBkrAdvPaymentsToCarrier nchar(1)
        Declare @ins_prcp_TrnBkrCollectsFrom nvarchar(40), @del_prcp_TrnBkrCollectsFrom nvarchar(40)
        Declare @ins_prcp_TrnLogAdvPaymentsToCarrier nchar(1), @del_prcp_TrnLogAdvPaymentsToCarrier nchar(1)
        Declare @ins_prcp_TrnLogCollectsFrom nvarchar(40), @del_prcp_TrnLogCollectsFrom nvarchar(40)
        Declare @ins_prcp_TrnLogResponsibleForPaymentOfClaims nchar(1), @del_prcp_TrnLogResponsibleForPaymentOfClaims nchar(1)
        Declare @ins_prcp_FrtLiableForPaymentToCarrier nchar(1), @del_prcp_FrtLiableForPaymentToCarrier nchar(1)
        Declare @ins_prcp_SellCoOpPct int, @del_prcp_SellCoOpPct int
        Declare @ins_prcp_SellRetailYardPct int, @del_prcp_SellRetailYardPct int
        Declare @ins_prcp_SellOtherPct int, @del_prcp_SellOtherPct int
        Declare @ins_prcp_SellHomeCenterPct int, @del_prcp_SellHomeCenterPct int
        Declare @ins_prcp_SellSecManPct int, @del_prcp_SellSecManPct int
        Declare @ins_prcp_SellStockingWholesalePct int, @del_prcp_SellStockingWholesalePct int
        Declare @ins_prcp_SellOfficeWholesalePct int, @del_prcp_SellOfficeWholesalePct int
        Declare @ins_prcp_SellProDealerPct int, @del_prcp_SellProDealerPct int
        Declare @ins_prcp_SellWholesalePct int, @del_prcp_SellWholesalePct int
        Declare @ins_prcp_SrcBuyMillsPct int, @del_prcp_SrcBuyMillsPct int
        Declare @ins_prcp_SrcBuyOtherPct int, @del_prcp_SrcBuyOtherPct int
        Declare @ins_prcp_SrcBuySecManPct int, @del_prcp_SrcBuySecManPct int
        Declare @ins_prcp_VolumeBoardFeetPerYear nvarchar(100), @del_prcp_VolumeBoardFeetPerYear nvarchar(100)
        Declare @ins_prcp_VolumeTruckLoadsPerYear nvarchar(100), @del_prcp_VolumeTruckLoadsPerYear nvarchar(100)
        Declare @ins_prcp_VolumeCarLoadsPerYear nvarchar(100), @del_prcp_VolumeCarLoadsPerYear nvarchar(100)
        Declare @ins_prcp_StorageCoveredSF nvarchar(40), @del_prcp_StorageCoveredSF nvarchar(40)
        Declare @ins_prcp_StorageUncoveredSF nvarchar(40), @del_prcp_StorageUncoveredSF nvarchar(40)
        Declare @ins_prcp_RailServiceProvider1 nvarchar(200), @del_prcp_RailServiceProvider1 nvarchar(200)
        Declare @ins_prcp_RailServiceProvider2 nvarchar(200), @del_prcp_RailServiceProvider2 nvarchar(200)

		Declare @ins_prcp_SalvageDistressedProduce nchar(1), @del_prcp_SalvageDistressedProduce nchar(1)	
		Declare @ins_prcp_StorageOwnLease nvarchar(40), @del_prcp_StorageOwnLease nvarchar(40)
		Declare @ins_prcp_SellBuyOthersPct int, @del_prcp_SellBuyOthersPct int
		Declare @ins_prcp_GrowsOwnProducePct int, @del_prcp_GrowsOwnProducePct int
		
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
            @ins_prcp_SrcBuyOfficeWholesalePct = i.prcp_SrcBuyOfficeWholesalePct, @del_prcp_SrcBuyOfficeWholesalePct = d.prcp_SrcBuyOfficeWholesalePct,
            @ins_prcp_SrcBuyStockingWholesalePct = i.prcp_SrcBuyStockingWholesalePct, @del_prcp_SrcBuyStockingWholesalePct = d.prcp_SrcBuyStockingWholesalePct,
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
            @ins_prcp_TrkrLiabilityCarrier = i.prcp_TrkrLiabilityCarrier, @del_prcp_TrkrLiabilityCarrier = d.prcp_TrkrLiabilityCarrier,
            @ins_prcp_TrkrCargoAmount = i.prcp_TrkrCargoAmount, @del_prcp_TrkrCargoAmount = d.prcp_TrkrCargoAmount,
            @ins_prcp_TrkrCargoCarrier = i.prcp_TrkrCargoCarrier, @del_prcp_TrkrCargoCarrier = d.prcp_TrkrCargoCarrier,
            @ins_prcp_StorageWarehouses = i.prcp_StorageWarehouses, @del_prcp_StorageWarehouses = d.prcp_StorageWarehouses,
            @ins_prcp_StorageSF = i.prcp_StorageSF, @del_prcp_StorageSF = d.prcp_StorageSF,
            @ins_prcp_StorageCF = i.prcp_StorageCF, @del_prcp_StorageCF = d.prcp_StorageCF,
            @ins_prcp_StorageBushel = i.prcp_StorageBushel, @del_prcp_StorageBushel = d.prcp_StorageBushel,
            @ins_prcp_StorageCarlots = i.prcp_StorageCarlots, @del_prcp_StorageCarlots = d.prcp_StorageCarlots,
            @ins_prcp_ColdStorage = i.prcp_ColdStorage, @del_prcp_ColdStorage = d.prcp_ColdStorage,
            @ins_prcp_ColdStorageLeased = i.prcp_ColdStorageLeased, @del_prcp_ColdStorageLeased = d.prcp_ColdStorageLeased,
            @ins_prcp_RipeningStorage = i.prcp_RipeningStorage, @del_prcp_RipeningStorage = d.prcp_RipeningStorage,
            @ins_prcp_HumidityStorage = i.prcp_HumidityStorage, @del_prcp_HumidityStorage = d.prcp_HumidityStorage,
            @ins_prcp_AtmosphereStorage = i.prcp_AtmosphereStorage, @del_prcp_AtmosphereStorage = d.prcp_AtmosphereStorage,
            @ins_prcp_Organic = i.prcp_Organic, @del_prcp_Organic = d.prcp_Organic,
            @ins_prcp_FoodSafetyCertified = i.prcp_FoodSafetyCertified, @del_prcp_FoodSafetyCertified = d.prcp_FoodSafetyCertified,
            @ins_prcp_SellFoodWholesaler = i.prcp_SellFoodWholesaler, @del_prcp_SellFoodWholesaler = d.prcp_SellFoodWholesaler,
            @ins_prcp_SellRetailGrocery = i.prcp_SellRetailGrocery, @del_prcp_SellRetailGrocery = d.prcp_SellRetailGrocery,
            @ins_prcp_SellInstitutions = i.prcp_SellInstitutions, @del_prcp_SellInstitutions = d.prcp_SellInstitutions,
            @ins_prcp_SellRestaurants = i.prcp_SellRestaurants, @del_prcp_SellRestaurants = d.prcp_SellRestaurants,
            @ins_prcp_SellMilitary = i.prcp_SellMilitary, @del_prcp_SellMilitary = d.prcp_SellMilitary,
            @ins_prcp_SellDistributors = i.prcp_SellDistributors, @del_prcp_SellDistributors = d.prcp_SellDistributors,
            @ins_prcp_TrkBkrCollectsFreightPct = i.prcp_TrkBkrCollectsFreightPct, @del_prcp_TrkBkrCollectsFreightPct = d.prcp_TrkBkrCollectsFreightPct,
            @ins_prcp_TrkBkrPaymentFreightPct = i.prcp_TrkBkrPaymentFreightPct, @del_prcp_TrkBkrPaymentFreightPct = d.prcp_TrkBkrPaymentFreightPct,
            @ins_prcp_TrkBkrCollectsFrom = i.prcp_TrkBkrCollectsFrom, @del_prcp_TrkBkrCollectsFrom = d.prcp_TrkBkrCollectsFrom,
            @ins_prcp_TrkBkrResponsibleForPaymentOfClaims = i.prcp_TrkBkrResponsibleForPaymentOfClaims, @del_prcp_TrkBkrResponsibleForPaymentOfClaims = d.prcp_TrkBkrResponsibleForPaymentOfClaims,
            @ins_prcp_BkrCollectRemitForShipper = i.prcp_BkrCollectRemitForShipper, @del_prcp_BkrCollectRemitForShipper = d.prcp_BkrCollectRemitForShipper,
            @ins_prcp_SrcTakePhysicalPossessionPct = i.prcp_SrcTakePhysicalPossessionPct, @del_prcp_SrcTakePhysicalPossessionPct = d.prcp_SrcTakePhysicalPossessionPct,
            @ins_prcp_SellShippingSeason = i.prcp_SellShippingSeason, @del_prcp_SellShippingSeason = d.prcp_SellShippingSeason,
            @ins_prcp_TrnBkrArrangesTransportation = i.prcp_TrnBkrArrangesTransportation, @del_prcp_TrnBkrArrangesTransportation = d.prcp_TrnBkrArrangesTransportation,
            @ins_prcp_TrnBkrAdvPaymentsToCarrier = i.prcp_TrnBkrAdvPaymentsToCarrier, @del_prcp_TrnBkrAdvPaymentsToCarrier = d.prcp_TrnBkrAdvPaymentsToCarrier,
            @ins_prcp_TrnBkrCollectsFrom = i.prcp_TrnBkrCollectsFrom, @del_prcp_TrnBkrCollectsFrom = d.prcp_TrnBkrCollectsFrom,
            @ins_prcp_TrnLogAdvPaymentsToCarrier = i.prcp_TrnLogAdvPaymentsToCarrier, @del_prcp_TrnLogAdvPaymentsToCarrier = d.prcp_TrnLogAdvPaymentsToCarrier,
            @ins_prcp_TrnLogCollectsFrom = i.prcp_TrnLogCollectsFrom, @del_prcp_TrnLogCollectsFrom = d.prcp_TrnLogCollectsFrom,
            @ins_prcp_TrnLogResponsibleForPaymentOfClaims = i.prcp_TrnLogResponsibleForPaymentOfClaims, @del_prcp_TrnLogResponsibleForPaymentOfClaims = d.prcp_TrnLogResponsibleForPaymentOfClaims,
            @ins_prcp_FrtLiableForPaymentToCarrier = i.prcp_FrtLiableForPaymentToCarrier, @del_prcp_FrtLiableForPaymentToCarrier = d.prcp_FrtLiableForPaymentToCarrier,
            @ins_prcp_SellCoOpPct = i.prcp_SellCoOpPct, @del_prcp_SellCoOpPct = d.prcp_SellCoOpPct,
            @ins_prcp_SellRetailYardPct = i.prcp_SellRetailYardPct, @del_prcp_SellRetailYardPct = d.prcp_SellRetailYardPct,
            @ins_prcp_SellOtherPct = i.prcp_SellOtherPct, @del_prcp_SellOtherPct = d.prcp_SellOtherPct,
            @ins_prcp_SellHomeCenterPct = i.prcp_SellHomeCenterPct, @del_prcp_SellHomeCenterPct = d.prcp_SellHomeCenterPct,
            @ins_prcp_SellSecManPct = i.prcp_SellSecManPct, @del_prcp_SellSecManPct = d.prcp_SellSecManPct,
            @ins_prcp_SellStockingWholesalePct = i.prcp_SellStockingWholesalePct, @del_prcp_SellStockingWholesalePct = d.prcp_SellStockingWholesalePct,
            @ins_prcp_SellOfficeWholesalePct = i.prcp_SellOfficeWholesalePct, @del_prcp_SellOfficeWholesalePct = d.prcp_SellOfficeWholesalePct,
            @ins_prcp_SellProDealerPct = i.prcp_SellProDealerPct, @del_prcp_SellProDealerPct = d.prcp_SellProDealerPct,
            @ins_prcp_SellWholesalePct = i.prcp_SellWholesalePct, @del_prcp_SellWholesalePct = d.prcp_SellWholesalePct,
            @ins_prcp_SrcBuyMillsPct = i.prcp_SrcBuyMillsPct, @del_prcp_SrcBuyMillsPct = d.prcp_SrcBuyMillsPct,
            @ins_prcp_SrcBuyOtherPct = i.prcp_SrcBuyOtherPct, @del_prcp_SrcBuyOtherPct = d.prcp_SrcBuyOtherPct,
            @ins_prcp_SrcBuySecManPct = i.prcp_SrcBuySecManPct, @del_prcp_SrcBuySecManPct = d.prcp_SrcBuySecManPct,
            @ins_prcp_VolumeBoardFeetPerYear = i.prcp_VolumeBoardFeetPerYear, @del_prcp_VolumeBoardFeetPerYear = d.prcp_VolumeBoardFeetPerYear,
            @ins_prcp_VolumeTruckLoadsPerYear = i.prcp_VolumeTruckLoadsPerYear, @del_prcp_VolumeTruckLoadsPerYear = d.prcp_VolumeTruckLoadsPerYear,
            @ins_prcp_VolumeCarLoadsPerYear = i.prcp_VolumeCarLoadsPerYear, @del_prcp_VolumeCarLoadsPerYear = d.prcp_VolumeCarLoadsPerYear,
            @ins_prcp_StorageCoveredSF = i.prcp_StorageCoveredSF, @del_prcp_StorageCoveredSF = d.prcp_StorageCoveredSF,
            @ins_prcp_StorageUncoveredSF = i.prcp_StorageUncoveredSF, @del_prcp_StorageUncoveredSF = d.prcp_StorageUncoveredSF,
            @ins_prcp_RailServiceProvider1 = i.prcp_RailServiceProvider1, @del_prcp_RailServiceProvider1 = d.prcp_RailServiceProvider1,
            @ins_prcp_RailServiceProvider2 = i.prcp_RailServiceProvider2, @del_prcp_RailServiceProvider2 = d.prcp_RailServiceProvider2,
			@ins_prcp_SalvageDistressedProduce = i.prcp_SalvageDistressedProduce, @del_prcp_SalvageDistressedProduce = d.prcp_SalvageDistressedProduce,
			@ins_prcp_StorageOwnLease = i.prcp_StorageOwnLease, @del_prcp_StorageOwnLease = d.prcp_StorageOwnLease,
			@ins_prcp_SellBuyOthersPct = i.prcp_SellBuyOthersPct, @del_prcp_SellBuyOthersPct = d.prcp_SellBuyOthersPct,
			@ins_prcp_GrowsOwnProducePct = i.prcp_GrowsOwnProducePct, @del_prcp_GrowsOwnProducePct = d.prcp_GrowsOwnProducePct
        FROM Inserted i
        LEFT OUTER JOIN deleted d ON i.prcp_CompanyProfileId = d.prcp_CompanyProfileId

        -- prcp_CorporateStructure
        IF  (  Update(prcp_CorporateStructure))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_CorporateStructure' AND capt_code = @ins_prcp_CorporateStructure
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_CorporateStructure)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_CorporateStructure' AND capt_code = @del_prcp_CorporateStructure
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_CorporateStructure)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_CorporateStructure', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END



        -- prcp_Volume
        IF  (  Update(prcp_Volume))
        BEGIN
			DECLARE @IndustryType varchar(40), @capt_family varchar(40)
			SET @capt_family = 'prcp_Volume';
			
			SELECT @IndustryType = comp_PRIndustryType FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@TrxKeyId;
			IF (@IndustryType = 'L') BEGIN
				SET @capt_family = 'prcp_VolumeL';
			END


            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family=@capt_family AND capt_code = @ins_prcp_Volume
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_Volume)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family=@capt_family AND capt_code = @del_prcp_Volume
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_Volume)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_Volume', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_FTEmployees
        IF  (  Update(prcp_FTEmployees))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='NumEmployees' AND capt_code = @ins_prcp_FTEmployees
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_FTEmployees)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='NumEmployees' AND capt_code = @del_prcp_FTEmployees
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_FTEmployees)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_FTEmployees', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_PTEmployees
        IF  (  Update(prcp_PTEmployees))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='NumEmployees' AND capt_code = @ins_prcp_PTEmployees
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_PTEmployees)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='NumEmployees' AND capt_code = @del_prcp_PTEmployees
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_PTEmployees)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_PTEmployees', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyBrokersPct
        IF  (  Update(prcp_SrcBuyBrokersPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcBuyBrokersPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcBuyBrokersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyBrokersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyWholesalePct
        IF  (  Update(prcp_SrcBuyWholesalePct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcBuyWholesalePct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcBuyWholesalePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyWholesalePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyShippersPct
        IF  (  Update(prcp_SrcBuyShippersPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcBuyShippersPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcBuyShippersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyShippersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyExportersPct
        IF  (  Update(prcp_SrcBuyExportersPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcBuyExportersPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcBuyExportersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyExportersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellBrokersPct
        IF  (  Update(prcp_SellBrokersPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellBrokersPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellBrokersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellBrokersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyOfficeWholesalePct
        IF  (  Update(prcp_SrcBuyOfficeWholesalePct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcBuyOfficeWholesalePct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcBuyOfficeWholesalePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyOfficeWholesalePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyStockingWholesalePct
        IF  (  Update(prcp_SrcBuyStockingWholesalePct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcBuyStockingWholesalePct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcBuyStockingWholesalePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyStockingWholesalePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellDomesticBuyersPct
        IF  (  Update(prcp_SellDomesticBuyersPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellDomesticBuyersPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellDomesticBuyersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellDomesticBuyersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellExportersPct
        IF  (  Update(prcp_SellExportersPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellExportersPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellExportersPct)
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
            SET @OldValue =  convert(varchar(max), @del_prcp_BkrTakeTitlePct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_BkrTakeTitlePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrTakeTitlePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrTakePossessionPct
        IF  (  Update(prcp_BkrTakePossessionPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_BkrTakePossessionPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_BkrTakePossessionPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrTakePossessionPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrCollectPct
        IF  (  Update(prcp_BkrCollectPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_BkrCollectPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_BkrCollectPct)
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
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_BkrReceive' AND capt_code = @ins_prcp_BkrReceive
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_BkrReceive)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_BkrReceive' AND capt_code = @del_prcp_BkrReceive
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_BkrReceive)

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
            SET @OldValue =  convert(varchar(max), @del_prcp_TrkrDirectHaulsPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_TrkrDirectHaulsPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrDirectHaulsPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTPHaulsPct
        IF  (  Update(prcp_TrkrTPHaulsPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_TrkrTPHaulsPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_TrkrTPHaulsPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTPHaulsPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrProducePct
        IF  (  Update(prcp_TrkrProducePct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_TrkrProducePct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_TrkrProducePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrProducePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrOtherColdPct
        IF  (  Update(prcp_TrkrOtherColdPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_TrkrOtherColdPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_TrkrOtherColdPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrOtherColdPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrOtherWarmPct
        IF  (  Update(prcp_TrkrOtherWarmPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_TrkrOtherWarmPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_TrkrOtherWarmPct)
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
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrTrucksOwned
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrTrucksOwned)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrTrucksOwned
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrTrucksOwned)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTrucksOwned', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTrucksLeased
        IF  (  Update(prcp_TrkrTrucksLeased))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrTrucksLeased
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrTrucksLeased)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrTrucksLeased
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrTrucksLeased)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTrucksLeased', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTrailersOwned
        IF  (  Update(prcp_TrkrTrailersOwned))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrTrailersOwned
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrTrailersOwned)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrTrailersOwned
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrTrailersOwned)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTrailersOwned', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTrailersLeased
        IF  (  Update(prcp_TrkrTrailersLeased))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrTrailersLeased
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrTrailersLeased)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrTrailersLeased
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrTrailersLeased)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTrailersLeased', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrPowerUnits
        IF  (  Update(prcp_TrkrPowerUnits))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrPowerUnits
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrPowerUnits)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrPowerUnits
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrPowerUnits)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrPowerUnits', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrReefer
        IF  (  Update(prcp_TrkrReefer))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrReefer
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrReefer)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrReefer
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrReefer)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrReefer', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrDryVan
        IF  (  Update(prcp_TrkrDryVan))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrDryVan
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrDryVan)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrDryVan
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrDryVan)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrDryVan', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrFlatbed
        IF  (  Update(prcp_TrkrFlatbed))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrFlatbed
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrFlatbed)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrFlatbed
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrFlatbed)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrFlatbed', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrPiggyback
        IF  (  Update(prcp_TrkrPiggyback))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrPiggyback
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrPiggyback)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrPiggyback
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrPiggyback)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrPiggyback', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrTanker
        IF  (  Update(prcp_TrkrTanker))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrTanker
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrTanker)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrTanker
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrTanker)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrTanker', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrContainer
        IF  (  Update(prcp_TrkrContainer))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrContainer
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrContainer)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrContainer
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrContainer)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrContainer', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrOther
        IF  (  Update(prcp_TrkrOther))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @ins_prcp_TrkrOther
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkrOther)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='TruckEquip' AND capt_code = @del_prcp_TrkrOther
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkrOther)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrOther', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrLiabilityAmount
        IF  (  Update(prcp_TrkrLiabilityAmount))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_TrkrLiabilityAmount)
            SET @NewValue =  convert(varchar(max), @ins_prcp_TrkrLiabilityAmount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrLiabilityAmount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrLiabilityCarrier
        IF  (  Update(prcp_TrkrLiabilityCarrier))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrLiabilityCarrier
            SET @NewValue =  @ins_prcp_TrkrLiabilityCarrier
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrLiabilityCarrier', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrCargoAmount
        IF  (  Update(prcp_TrkrCargoAmount))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_TrkrCargoAmount)
            SET @NewValue =  convert(varchar(max), @ins_prcp_TrkrCargoAmount)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrCargoAmount', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkrCargoCarrier
        IF  (  Update(prcp_TrkrCargoCarrier))
        BEGIN
            SET @OldValue =  @del_prcp_TrkrCargoCarrier
            SET @NewValue =  @ins_prcp_TrkrCargoCarrier
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkrCargoCarrier', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageWarehouses
        IF  (  Update(prcp_StorageWarehouses))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_StorageWarehouses)
            SET @NewValue =  convert(varchar(max), @ins_prcp_StorageWarehouses)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageWarehouses', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageSF
        IF  (  Update(prcp_StorageSF))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageSF' AND capt_code = @ins_prcp_StorageSF
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_StorageSF)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageSF' AND capt_code = @del_prcp_StorageSF
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_StorageSF)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageSF', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageCF
        IF  (  Update(prcp_StorageCF))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageCF' AND capt_code = @ins_prcp_StorageCF
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_StorageCF)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageCF' AND capt_code = @del_prcp_StorageCF
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_StorageCF)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageCF', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageBushel
        IF  (  Update(prcp_StorageBushel))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageBushel' AND capt_code = @ins_prcp_StorageBushel
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_StorageBushel)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageBushel' AND capt_code = @del_prcp_StorageBushel
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_StorageBushel)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageBushel', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageCarlots
        IF  (  Update(prcp_StorageCarlots))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageCarlots' AND capt_code = @ins_prcp_StorageCarlots
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_StorageCarlots)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageCarlots' AND capt_code = @del_prcp_StorageCarlots
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_StorageCarlots)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageCarlots', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_ColdStorage
        IF  (  Update(prcp_ColdStorage))
        BEGIN
            SET @OldValue =  @del_prcp_ColdStorage
            SET @NewValue =  @ins_prcp_ColdStorage
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_ColdStorage', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_ColdStorageLeased
        IF  (  Update(prcp_ColdStorageLeased))
        BEGIN
            SET @OldValue =  @del_prcp_ColdStorageLeased
            SET @NewValue =  @ins_prcp_ColdStorageLeased
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_ColdStorageLeased', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
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

        -- prcp_Organic
        IF  (  Update(prcp_Organic))
        BEGIN
            SET @OldValue =  @del_prcp_Organic
            SET @NewValue =  @ins_prcp_Organic
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_Organic', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_FoodSafetyCertified
        IF  (  Update(prcp_FoodSafetyCertified))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_FoodSafetyCertified' AND capt_code = @ins_prcp_FoodSafetyCertified
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_FoodSafetyCertified)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_FoodSafetyCertified' AND capt_code = @del_prcp_FoodSafetyCertified
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_FoodSafetyCertified)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_FoodSafetyCertified', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
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
        -- prcp_TrkBkrCollectsFreightPct
        IF  (  Update(prcp_TrkBkrCollectsFreightPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_TrkBkrCollectsFreightPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_TrkBkrCollectsFreightPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkBkrCollectsFreightPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkBkrPaymentFreightPct
        IF  (  Update(prcp_TrkBkrPaymentFreightPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_TrkBkrPaymentFreightPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_TrkBkrPaymentFreightPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkBkrPaymentFreightPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkBkrCollectsFrom
        IF  (  Update(prcp_TrkBkrCollectsFrom))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_CollectsFrom' AND capt_code = @ins_prcp_TrkBkrCollectsFrom
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrkBkrCollectsFrom)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_CollectsFrom' AND capt_code = @del_prcp_TrkBkrCollectsFrom
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrkBkrCollectsFrom)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkBkrCollectsFrom', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrkBkrResponsibleForPaymentOfClaims
        IF  (  Update(prcp_TrkBkrResponsibleForPaymentOfClaims))
        BEGIN
            SET @OldValue =  @del_prcp_TrkBkrResponsibleForPaymentOfClaims
            SET @NewValue =  @ins_prcp_TrkBkrResponsibleForPaymentOfClaims
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrkBkrResponsibleForPaymentOfClaims', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_BkrCollectRemitForShipper
        IF  (  Update(prcp_BkrCollectRemitForShipper))
        BEGIN
            SET @OldValue =  @del_prcp_BkrCollectRemitForShipper
            SET @NewValue =  @ins_prcp_BkrCollectRemitForShipper
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_BkrCollectRemitForShipper', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcTakePhysicalPossessionPct
        IF  (  Update(prcp_SrcTakePhysicalPossessionPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcTakePhysicalPossessionPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcTakePhysicalPossessionPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcTakePhysicalPossessionPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellShippingSeason
        IF  (  Update(prcp_SellShippingSeason))
        BEGIN
            SET @OldValue =  @del_prcp_SellShippingSeason
            SET @NewValue =  @ins_prcp_SellShippingSeason
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellShippingSeason', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrnBkrArrangesTransportation
        IF  (  Update(prcp_TrnBkrArrangesTransportation))
        BEGIN
            SET @OldValue =  @del_prcp_TrnBkrArrangesTransportation
            SET @NewValue =  @ins_prcp_TrnBkrArrangesTransportation
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrnBkrArrangesTransportation', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrnBkrAdvPaymentsToCarrier
        IF  (  Update(prcp_TrnBkrAdvPaymentsToCarrier))
        BEGIN
            SET @OldValue =  @del_prcp_TrnBkrAdvPaymentsToCarrier
            SET @NewValue =  @ins_prcp_TrnBkrAdvPaymentsToCarrier
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrnBkrAdvPaymentsToCarrier', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrnBkrCollectsFrom
        IF  (  Update(prcp_TrnBkrCollectsFrom))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_CollectsFrom' AND capt_code = @ins_prcp_TrnBkrCollectsFrom
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrnBkrCollectsFrom)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_CollectsFrom' AND capt_code = @del_prcp_TrnBkrCollectsFrom
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrnBkrCollectsFrom)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrnBkrCollectsFrom', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrnLogAdvPaymentsToCarrier
        IF  (  Update(prcp_TrnLogAdvPaymentsToCarrier))
        BEGIN
            SET @OldValue =  @del_prcp_TrnLogAdvPaymentsToCarrier
            SET @NewValue =  @ins_prcp_TrnLogAdvPaymentsToCarrier
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrnLogAdvPaymentsToCarrier', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrnLogCollectsFrom
        IF  (  Update(prcp_TrnLogCollectsFrom))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_CollectsFrom' AND capt_code = @ins_prcp_TrnLogCollectsFrom
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_TrnLogCollectsFrom)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_CollectsFrom' AND capt_code = @del_prcp_TrnLogCollectsFrom
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_TrnLogCollectsFrom)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrnLogCollectsFrom', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_TrnLogResponsibleForPaymentOfClaims
        IF  (  Update(prcp_TrnLogResponsibleForPaymentOfClaims))
        BEGIN
            SET @OldValue =  @del_prcp_TrnLogResponsibleForPaymentOfClaims
            SET @NewValue =  @ins_prcp_TrnLogResponsibleForPaymentOfClaims
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_TrnLogResponsibleForPaymentOfClaims', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_FrtLiableForPaymentToCarrier
        IF  (  Update(prcp_FrtLiableForPaymentToCarrier))
        BEGIN
            SET @OldValue =  @del_prcp_FrtLiableForPaymentToCarrier
            SET @NewValue =  @ins_prcp_FrtLiableForPaymentToCarrier
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_FrtLiableForPaymentToCarrier', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellCoOpPct
        IF  (  Update(prcp_SellCoOpPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellCoOpPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellCoOpPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellCoOpPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellRetailYardPct
        IF  (  Update(prcp_SellRetailYardPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellRetailYardPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellRetailYardPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellRetailYardPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellOtherPct
        IF  (  Update(prcp_SellOtherPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellOtherPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellOtherPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellOtherPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellHomeCenterPct
        IF  (  Update(prcp_SellHomeCenterPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellHomeCenterPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellHomeCenterPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellHomeCenterPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellSecManPct
        IF  (  Update(prcp_SellSecManPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellSecManPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellSecManPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellSecManPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellStockingWholesalePct
        IF  (  Update(prcp_SellStockingWholesalePct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellStockingWholesalePct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellStockingWholesalePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellStockingWholesalePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellOfficeWholesalePct
        IF  (  Update(prcp_SellOfficeWholesalePct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellOfficeWholesalePct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellOfficeWholesalePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellOfficeWholesalePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellProDealerPct
        IF  (  Update(prcp_SellProDealerPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellProDealerPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellProDealerPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellProDealerPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SellWholesalePct
        IF  (  Update(prcp_SellWholesalePct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellWholesalePct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellWholesalePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellWholesalePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyMillsPct
        IF  (  Update(prcp_SrcBuyMillsPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcBuyMillsPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcBuyMillsPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyMillsPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuyOtherPct
        IF  (  Update(prcp_SrcBuyOtherPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcBuyOtherPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcBuyOtherPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuyOtherPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SrcBuySecManPct
        IF  (  Update(prcp_SrcBuySecManPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SrcBuySecManPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SrcBuySecManPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SrcBuySecManPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_VolumeBoardFeetPerYear
        IF  (  Update(prcp_VolumeBoardFeetPerYear))
        BEGIN
            SET @OldValue =  @del_prcp_VolumeBoardFeetPerYear
            SET @NewValue =  @ins_prcp_VolumeBoardFeetPerYear
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_VolumeBoardFeetPerYear', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_VolumeTruckLoadsPerYear
        IF  (  Update(prcp_VolumeTruckLoadsPerYear))
        BEGIN
            SET @OldValue =  @del_prcp_VolumeTruckLoadsPerYear
            SET @NewValue =  @ins_prcp_VolumeTruckLoadsPerYear
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_VolumeTruckLoadsPerYear', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_VolumeCarLoadsPerYear
        IF  (  Update(prcp_VolumeCarLoadsPerYear))
        BEGIN
            SET @OldValue =  @del_prcp_VolumeCarLoadsPerYear
            SET @NewValue =  @ins_prcp_VolumeCarLoadsPerYear
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_VolumeCarLoadsPerYear', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageCoveredSF
        IF  (  Update(prcp_StorageCoveredSF))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageSF' AND capt_code = @ins_prcp_StorageCoveredSF
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_StorageCoveredSF)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageSF' AND capt_code = @del_prcp_StorageCoveredSF
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_StorageCoveredSF)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageCoveredSF', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_StorageUncoveredSF
        IF  (  Update(prcp_StorageUncoveredSF))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageSF' AND capt_code = @ins_prcp_StorageUncoveredSF
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_StorageUncoveredSF)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageSF' AND capt_code = @del_prcp_StorageUncoveredSF
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_StorageUncoveredSF)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageUncoveredSF', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_RailServiceProvider1
        IF  (  Update(prcp_RailServiceProvider1))
        BEGIN
            SET @OldValue =  @del_prcp_RailServiceProvider1
            SET @NewValue =  @ins_prcp_RailServiceProvider1
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_RailServiceProvider1', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_RailServiceProvider2
        IF  (  Update(prcp_RailServiceProvider2))
        BEGIN
            SET @OldValue =  @del_prcp_RailServiceProvider2
            SET @NewValue =  @ins_prcp_RailServiceProvider2
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_RailServiceProvider2', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
        -- prcp_SalvageDistressedProduce
        IF  (  Update(prcp_SalvageDistressedProduce))
        BEGIN
            SET @OldValue =  @del_prcp_SalvageDistressedProduce
            SET @NewValue =  @ins_prcp_SalvageDistressedProduce
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SalvageDistressedProduce', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END

        -- prcp_StorageOwnLease
        IF  (  Update(prcp_StorageOwnLease))
        BEGIN
            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageOwnLease' AND capt_code = @ins_prcp_StorageOwnLease
            SET @NewValue = COALESCE(@NewValueTemp,  @ins_prcp_StorageOwnLease)

            SET @NewValueTemp = NULL
            SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family='prcp_StorageOwnLease' AND capt_code = @del_prcp_StorageOwnLease
            SET @OldValue = COALESCE(@NewValueTemp,  @del_prcp_StorageOwnLease)

            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_StorageOwnLease', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END
	
        -- prcp_SellBuyOthersPct
        IF  (  Update(prcp_SellBuyOthersPct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_SellBuyOthersPct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_SellBuyOthersPct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_SellBuyOthersPct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END	

        -- prcp_SellBuyOthersPct
        IF  (  Update(prcp_GrowsOwnProducePct))
        BEGIN
            SET @OldValue =  convert(varchar(max), @del_prcp_GrowsOwnProducePct)
            SET @NewValue =  convert(varchar(max), @ins_prcp_GrowsOwnProducePct)
            exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 'prcp_GrowsOwnProducePct', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        END	
		
    END


    IF (@DelCount = 0) BEGIN
		INSERT INTO PRCompanyProfile 
		SELECT * FROM inserted i 
	END ELSE
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
        PRCompanyProfile.prcp_SrcBuyOfficeWholesalePct=i.prcp_SrcBuyOfficeWholesalePct, 
        PRCompanyProfile.prcp_SrcBuyStockingWholesalePct=i.prcp_SrcBuyStockingWholesalePct, 
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
        PRCompanyProfile.prcp_ColdStorageLeased=i.prcp_ColdStorageLeased, 
        PRCompanyProfile.prcp_RipeningStorage=i.prcp_RipeningStorage, 
        PRCompanyProfile.prcp_HumidityStorage=i.prcp_HumidityStorage, 
        PRCompanyProfile.prcp_AtmosphereStorage=i.prcp_AtmosphereStorage, 
        PRCompanyProfile.prcp_Organic=i.prcp_Organic, 
        PRCompanyProfile.prcp_FoodSafetyCertified=i.prcp_FoodSafetyCertified, 
        PRCompanyProfile.prcp_SellFoodWholesaler=i.prcp_SellFoodWholesaler, 
        PRCompanyProfile.prcp_SellRetailGrocery=i.prcp_SellRetailGrocery, 
        PRCompanyProfile.prcp_SellInstitutions=i.prcp_SellInstitutions, 
        PRCompanyProfile.prcp_SellRestaurants=i.prcp_SellRestaurants, 
        PRCompanyProfile.prcp_SellMilitary=i.prcp_SellMilitary, 
        PRCompanyProfile.prcp_SellDistributors=i.prcp_SellDistributors, 
        PRCompanyProfile.prcp_TrkBkrCollectsFreightPct=i.prcp_TrkBkrCollectsFreightPct, 
        PRCompanyProfile.prcp_TrkBkrPaymentFreightPct=i.prcp_TrkBkrPaymentFreightPct, 
        PRCompanyProfile.prcp_TrkBkrCollectsFrom=i.prcp_TrkBkrCollectsFrom, 
        PRCompanyProfile.prcp_TrkBkrResponsibleForPaymentOfClaims=i.prcp_TrkBkrResponsibleForPaymentOfClaims, 
        PRCompanyProfile.prcp_BkrCollectRemitForShipper=i.prcp_BkrCollectRemitForShipper, 
        PRCompanyProfile.prcp_SrcTakePhysicalPossessionPct=i.prcp_SrcTakePhysicalPossessionPct, 
        PRCompanyProfile.prcp_SellShippingSeason=i.prcp_SellShippingSeason, 
        PRCompanyProfile.prcp_TrnBkrArrangesTransportation=i.prcp_TrnBkrArrangesTransportation, 
        PRCompanyProfile.prcp_TrnBkrAdvPaymentsToCarrier=i.prcp_TrnBkrAdvPaymentsToCarrier, 
        PRCompanyProfile.prcp_TrnBkrCollectsFrom=i.prcp_TrnBkrCollectsFrom, 
        PRCompanyProfile.prcp_TrnLogAdvPaymentsToCarrier=i.prcp_TrnLogAdvPaymentsToCarrier, 
        PRCompanyProfile.prcp_TrnLogCollectsFrom=i.prcp_TrnLogCollectsFrom, 
        PRCompanyProfile.prcp_TrnLogResponsibleForPaymentOfClaims=i.prcp_TrnLogResponsibleForPaymentOfClaims, 
        PRCompanyProfile.prcp_FrtLiableForPaymentToCarrier=i.prcp_FrtLiableForPaymentToCarrier, 
        PRCompanyProfile.prcp_SellCoOpPct=i.prcp_SellCoOpPct, 
        PRCompanyProfile.prcp_SellRetailYardPct=i.prcp_SellRetailYardPct, 
        PRCompanyProfile.prcp_SellOtherPct=i.prcp_SellOtherPct, 
        PRCompanyProfile.prcp_SellHomeCenterPct=i.prcp_SellHomeCenterPct, 
        PRCompanyProfile.prcp_SellSecManPct=i.prcp_SellSecManPct, 
        PRCompanyProfile.prcp_SellStockingWholesalePct=i.prcp_SellStockingWholesalePct, 
        PRCompanyProfile.prcp_SellOfficeWholesalePct=i.prcp_SellOfficeWholesalePct, 
        PRCompanyProfile.prcp_SellProDealerPct=i.prcp_SellProDealerPct, 
        PRCompanyProfile.prcp_SellWholesalePct=i.prcp_SellWholesalePct, 
        PRCompanyProfile.prcp_SrcBuyMillsPct=i.prcp_SrcBuyMillsPct, 
        PRCompanyProfile.prcp_SrcBuyOtherPct=i.prcp_SrcBuyOtherPct, 
        PRCompanyProfile.prcp_SrcBuySecManPct=i.prcp_SrcBuySecManPct, 
        PRCompanyProfile.prcp_VolumeBoardFeetPerYear=i.prcp_VolumeBoardFeetPerYear, 
        PRCompanyProfile.prcp_VolumeTruckLoadsPerYear=i.prcp_VolumeTruckLoadsPerYear, 
        PRCompanyProfile.prcp_VolumeCarLoadsPerYear=i.prcp_VolumeCarLoadsPerYear, 
        PRCompanyProfile.prcp_StorageCoveredSF=i.prcp_StorageCoveredSF, 
        PRCompanyProfile.prcp_StorageUncoveredSF=i.prcp_StorageUncoveredSF, 
        PRCompanyProfile.prcp_RailServiceProvider1=i.prcp_RailServiceProvider1, 
        PRCompanyProfile.prcp_RailServiceProvider2=i.prcp_RailServiceProvider2,
		PRCompanyProfile.prcp_SalvageDistressedProduce = i.prcp_SalvageDistressedProduce,
		PRCompanyProfile.prcp_StorageOwnLease = i.prcp_StorageOwnLease,
		PRCompanyProfile.prcp_SellBuyOthersPct = i.prcp_SellBuyOthersPct,
		PRCompanyProfile.prcp_GrowsOwnProducePct = i.prcp_GrowsOwnProducePct
        FROM inserted i 
          INNER JOIN PRCompanyProfile ON i.prcp_CompanyProfileId=PRCompanyProfile.prcp_CompanyProfileId
    END
END
GO


/* ************************************************************
 * Name:   dbo.trg_PRCompanyProfile_insdel
 * 
 * Table:  PRCompanyProfile
 * Action: FOR INSERT, DELETE
 * 
 * Description: Auto-generated FOR INSERT, DELETE trigger
 * ***********************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCompanyProfile_insdel]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_PRCompanyProfile_insdel]
GO

CREATE TRIGGER dbo.trg_PRCompanyProfile_insdel
ON PRCompanyProfile
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
    Declare @prcp_CompanyProfileId int
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
    Declare @ProcessTable TABLE(ProcessAction varchar(10), prcp_CompanyID int, prcp_CorporateStructure nvarchar(40), prcp_Volume nvarchar(40), prcp_FTEmployees nvarchar(40), prcp_PTEmployees nvarchar(40), prcp_SrcBuyBrokersPct int, prcp_SrcBuyWholesalePct int, prcp_SrcBuyShippersPct int, prcp_SrcBuyExportersPct int, prcp_SellBrokersPct int, prcp_SrcBuyOfficeWholesalePct int, prcp_SrcBuyStockingWholesalePct int, prcp_SellDomesticBuyersPct int, prcp_SellExportersPct int, prcp_SellBuyOthers nchar(1), prcp_SellDomesticAccountTypes nvarchar(255), prcp_BkrTakeTitlePct int, prcp_BkrTakePossessionPct int, prcp_BkrCollectPct int, prcp_BkrTakeFrieght nchar(1), prcp_BkrConfirmation nchar(1), prcp_BkrReceive nvarchar(40), prcp_BkrGroundInspections nchar(1), prcp_TrkrDirectHaulsPct int, prcp_TrkrTPHaulsPct int, prcp_TrkrProducePct int, prcp_TrkrOtherColdPct int, prcp_TrkrOtherWarmPct int, prcp_TrkrTeams nchar(1), prcp_TrkrTrucksOwned nvarchar(40), prcp_TrkrTrucksLeased nvarchar(40), prcp_TrkrTrailersOwned nvarchar(40), prcp_TrkrTrailersLeased nvarchar(40), prcp_TrkrPowerUnits nvarchar(40), prcp_TrkrReefer nvarchar(40), prcp_TrkrDryVan nvarchar(40), prcp_TrkrFlatbed nvarchar(40), prcp_TrkrPiggyback nvarchar(40), prcp_TrkrTanker nvarchar(40), prcp_TrkrContainer nvarchar(40), prcp_TrkrOther nvarchar(40), prcp_TrkrLiabilityAmount numeric, prcp_TrkrCargoAmount numeric, prcp_StorageWarehouses int, prcp_StorageSF nvarchar(40), prcp_StorageCF nvarchar(40), prcp_StorageBushel nvarchar(40), prcp_StorageCarlots nvarchar(40), prcp_ColdStorage nchar(1), prcp_ColdStorageLeased nchar(1), prcp_RipeningStorage nchar(1), prcp_HumidityStorage nchar(1), prcp_AtmosphereStorage nchar(1), prcp_Organic nchar(1), prcp_FoodSafetyCertified nvarchar(30), prcp_SellFoodWholesaler nchar(1), prcp_SellRetailGrocery nchar(1), prcp_SellInstitutions nchar(1), prcp_SellRestaurants nchar(1), prcp_SellMilitary nchar(1), prcp_SellDistributors nchar(1), prcp_TrkBkrCollectsFreightPct int, prcp_TrkBkrPaymentFreightPct int, prcp_TrkBkrCollectsFrom nvarchar(40), prcp_TrkBkrResponsibleForPaymentOfClaims nchar(1), prcp_BkrCollectRemitForShipper nchar(1), prcp_SrcTakePhysicalPossessionPct int, prcp_SellShippingSeason nvarchar(100), prcp_TrnBkrArrangesTransportation nvarchar(40), prcp_TrnBkrAdvPaymentsToCarrier nchar(1), prcp_TrnBkrCollectsFrom nvarchar(40), prcp_TrnLogAdvPaymentsToCarrier nchar(1), prcp_TrnLogCollectsFrom nvarchar(40), prcp_TrnLogResponsibleForPaymentOfClaims nchar(1), prcp_FrtLiableForPaymentToCarrier nchar(1), prcp_SellCoOpPct int, prcp_SellRetailYardPct int, prcp_SellOtherPct int, prcp_SellHomeCenterPct int, prcp_SellSecManPct int, prcp_SellStockingWholesalePct int, prcp_SellOfficeWholesalePct int, prcp_SellProDealerPct int, prcp_SellWholesalePct int, prcp_SrcBuyMillsPct int, prcp_SrcBuyOtherPct int, prcp_SrcBuySecManPct int, prcp_VolumeBoardFeetPerYear nvarchar(100), prcp_VolumeTruckLoadsPerYear nvarchar(100), prcp_VolumeCarLoadsPerYear nvarchar(100), prcp_StorageCoveredSF nvarchar(40), prcp_StorageUncoveredSF nvarchar(40), prcp_RailServiceProvider1 nvarchar(200), prcp_RailServiceProvider2 nvarchar(200))
    INSERT INTO @ProcessTable
        SELECT 'Insert',prcp_CompanyID,prcp_CorporateStructure,prcp_Volume,prcp_FTEmployees,prcp_PTEmployees,prcp_SrcBuyBrokersPct,prcp_SrcBuyWholesalePct,prcp_SrcBuyShippersPct,prcp_SrcBuyExportersPct,prcp_SellBrokersPct,prcp_SrcBuyOfficeWholesalePct,prcp_SrcBuyStockingWholesalePct,prcp_SellDomesticBuyersPct,prcp_SellExportersPct,prcp_SellBuyOthers,prcp_SellDomesticAccountTypes,prcp_BkrTakeTitlePct,prcp_BkrTakePossessionPct,prcp_BkrCollectPct,prcp_BkrTakeFrieght,prcp_BkrConfirmation,prcp_BkrReceive,prcp_BkrGroundInspections,prcp_TrkrDirectHaulsPct,prcp_TrkrTPHaulsPct,prcp_TrkrProducePct,prcp_TrkrOtherColdPct,prcp_TrkrOtherWarmPct,prcp_TrkrTeams,prcp_TrkrTrucksOwned,prcp_TrkrTrucksLeased,prcp_TrkrTrailersOwned,prcp_TrkrTrailersLeased,prcp_TrkrPowerUnits,prcp_TrkrReefer,prcp_TrkrDryVan,prcp_TrkrFlatbed,prcp_TrkrPiggyback,prcp_TrkrTanker,prcp_TrkrContainer,prcp_TrkrOther,prcp_TrkrLiabilityAmount,prcp_TrkrCargoAmount,prcp_StorageWarehouses,prcp_StorageSF,prcp_StorageCF,prcp_StorageBushel,prcp_StorageCarlots,prcp_ColdStorage,prcp_ColdStorageLeased,prcp_RipeningStorage,prcp_HumidityStorage,prcp_AtmosphereStorage,prcp_Organic,prcp_FoodSafetyCertified,prcp_SellFoodWholesaler,prcp_SellRetailGrocery,prcp_SellInstitutions,prcp_SellRestaurants,prcp_SellMilitary,prcp_SellDistributors,prcp_TrkBkrCollectsFreightPct,prcp_TrkBkrPaymentFreightPct,prcp_TrkBkrCollectsFrom,prcp_TrkBkrResponsibleForPaymentOfClaims,prcp_BkrCollectRemitForShipper,prcp_SrcTakePhysicalPossessionPct,prcp_SellShippingSeason,prcp_TrnBkrArrangesTransportation,prcp_TrnBkrAdvPaymentsToCarrier,prcp_TrnBkrCollectsFrom,prcp_TrnLogAdvPaymentsToCarrier,prcp_TrnLogCollectsFrom,prcp_TrnLogResponsibleForPaymentOfClaims,prcp_FrtLiableForPaymentToCarrier,prcp_SellCoOpPct,prcp_SellRetailYardPct,prcp_SellOtherPct,prcp_SellHomeCenterPct,prcp_SellSecManPct,prcp_SellStockingWholesalePct,prcp_SellOfficeWholesalePct,prcp_SellProDealerPct,prcp_SellWholesalePct,prcp_SrcBuyMillsPct,prcp_SrcBuyOtherPct,prcp_SrcBuySecManPct,prcp_VolumeBoardFeetPerYear,prcp_VolumeTruckLoadsPerYear,prcp_VolumeCarLoadsPerYear,prcp_StorageCoveredSF,prcp_StorageUncoveredSF,prcp_RailServiceProvider1,prcp_RailServiceProvider2
        FROM Inserted
    INSERT INTO @ProcessTable
        SELECT 'Delete',prcp_CompanyID,prcp_CorporateStructure,prcp_Volume,prcp_FTEmployees,prcp_PTEmployees,prcp_SrcBuyBrokersPct,prcp_SrcBuyWholesalePct,prcp_SrcBuyShippersPct,prcp_SrcBuyExportersPct,prcp_SellBrokersPct,prcp_SrcBuyOfficeWholesalePct,prcp_SrcBuyStockingWholesalePct,prcp_SellDomesticBuyersPct,prcp_SellExportersPct,prcp_SellBuyOthers,prcp_SellDomesticAccountTypes,prcp_BkrTakeTitlePct,prcp_BkrTakePossessionPct,prcp_BkrCollectPct,prcp_BkrTakeFrieght,prcp_BkrConfirmation,prcp_BkrReceive,prcp_BkrGroundInspections,prcp_TrkrDirectHaulsPct,prcp_TrkrTPHaulsPct,prcp_TrkrProducePct,prcp_TrkrOtherColdPct,prcp_TrkrOtherWarmPct,prcp_TrkrTeams,prcp_TrkrTrucksOwned,prcp_TrkrTrucksLeased,prcp_TrkrTrailersOwned,prcp_TrkrTrailersLeased,prcp_TrkrPowerUnits,prcp_TrkrReefer,prcp_TrkrDryVan,prcp_TrkrFlatbed,prcp_TrkrPiggyback,prcp_TrkrTanker,prcp_TrkrContainer,prcp_TrkrOther,prcp_TrkrLiabilityAmount,prcp_TrkrCargoAmount,prcp_StorageWarehouses,prcp_StorageSF,prcp_StorageCF,prcp_StorageBushel,prcp_StorageCarlots,prcp_ColdStorage,prcp_ColdStorageLeased,prcp_RipeningStorage,prcp_HumidityStorage,prcp_AtmosphereStorage,prcp_Organic,prcp_FoodSafetyCertified,prcp_SellFoodWholesaler,prcp_SellRetailGrocery,prcp_SellInstitutions,prcp_SellRestaurants,prcp_SellMilitary,prcp_SellDistributors,prcp_TrkBkrCollectsFreightPct,prcp_TrkBkrPaymentFreightPct,prcp_TrkBkrCollectsFrom,prcp_TrkBkrResponsibleForPaymentOfClaims,prcp_BkrCollectRemitForShipper,prcp_SrcTakePhysicalPossessionPct,prcp_SellShippingSeason,prcp_TrnBkrArrangesTransportation,prcp_TrnBkrAdvPaymentsToCarrier,prcp_TrnBkrCollectsFrom,prcp_TrnLogAdvPaymentsToCarrier,prcp_TrnLogCollectsFrom,prcp_TrnLogResponsibleForPaymentOfClaims,prcp_FrtLiableForPaymentToCarrier,prcp_SellCoOpPct,prcp_SellRetailYardPct,prcp_SellOtherPct,prcp_SellHomeCenterPct,prcp_SellSecManPct,prcp_SellStockingWholesalePct,prcp_SellOfficeWholesalePct,prcp_SellProDealerPct,prcp_SellWholesalePct,prcp_SrcBuyMillsPct,prcp_SrcBuyOtherPct,prcp_SrcBuySecManPct,prcp_VolumeBoardFeetPerYear,prcp_VolumeTruckLoadsPerYear,prcp_VolumeCarLoadsPerYear,prcp_StorageCoveredSF,prcp_StorageUncoveredSF,prcp_RailServiceProvider1,prcp_RailServiceProvider2
        FROM Deleted


/*
	CHW: Per defect 4334, we are creating duplicate transaction entries.
	I'm not sure why this is here because it's also in the I/U instead of
	trigger that normally handles these.

    Declare @prcp_Volume nvarchar(40)


    DECLARE crs CURSOR LOCAL FAST_FORWARD for
        SELECT ProcessAction, prcp_CompanyID,prcp_Volume
        FROM @ProcessTable
    OPEN crs
    FETCH NEXT FROM crs INTO @Action, @TrxKeyId ,@prcp_Volume
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
            SET @Msg = 'Changes Failed.  Company Profile ' + convert(varchar,@prcp_CompanyProfileId) + ' values can only be changed if a transaction is open.'
            ROLLBACK
            RAISERROR (@Msg, 16, 1)
            Return
        END

		DECLARE @IndustryType varchar(40), @capt_family varchar(40)
		SET @capt_family = 'prcp_Volume';
		
		SELECT @IndustryType = comp_PRIndustryType FROM Company WITH (NOLOCK) WHERE comp_CompanyID=@TrxKeyId;
		IF (@IndustryType = 'L') BEGIN
			SET @capt_family = 'prcp_VolumeL';
		END

        SET @NewValueTemp = NULL
        SELECT @NewValueTemp = capt_us FROM custom_captions WITH (NOLOCK)
                WHERE capt_family=@capt_family AND capt_code = @prcp_Volume
        SET @NewValueTemp = COALESCE(@NewValueTemp, convert(varchar(50), @prcp_Volume))
        SET @NewValue = COALESCE(@NewValue + ', ' + @NewValueTemp, @NewValueTemp, @NewValue)

        -- Assume Inserted
        SET @OldValue = NULL
        IF (@Action = 'Delete')
        BEGIN
            SET @OldValue = @NewValue
            SET @NewValue = NULL
        End
        exec usp_CreateTransactionDetail @prtx_TransactionId, 'Company Profile', @Action, 
            'prcp_Volume', @OldValue, @NewValue, @UserId, @TransactionDetailTypeId
        FETCH NEXT FROM crs INTO @Action, @TrxKeyId,@prcp_Volume
    End
    Close crs
    DEALLOCATE crs
*/
    SET NOCOUNT OFF
END
GO