
-- InstallAccpacCreationScripts
-- This file installs the TravantCRM Creation stored procs used
-- during the Blue Book Services CRM Database Build process

/*
 * Creates a Sage CRM field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateField
  @EntityName nvarchar(40) = NULL, 
  @FieldName nvarchar(40) = NULL, 
  @Caption nvarchar(255) = NULL, 
  @AccpacEntryType int = NULL,
  @AccpacEntrySize int = NULL,
  @DBFieldType varchar(255) = NULL,
  @DBFieldSize int = NULL,
  @AllowNull nchar(1) = 'Y',
  @IsRequired nchar(1) = 'N', 
  @AllowEdit nchar(1) = 'Y', 
  @IsUnique nchar(1) = 'N', 
  @DefaultValue nvarchar(255) = NULL, 
  @LookupFamily nvarchar(30) = NULL, 
  @LookupWidth nvarchar(15) = NULL, 
  @SearchValue nvarchar(255) = NULL, 
  @SystemCol nchar(1) = NULL,
  @Multiple nchar(1) = NULL,
  @SkipColumnCreation nchar(1) = NULL,
  @IsIdentity nchar(1) = 'N'
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @SQL varchar(8000)
  DECLARE @ComponentName varchar(80)
  DECLARE @NextId int
  DECLARE @Now DateTime

  -- Create a consistent time
  SET @Now = getDate()

  exec usp_TravantCRM_GetInstallComponentName NULL, @ComponentName OUTPUT
/*
  -- CHeck for a special table called tAccpacComponent
  -- if it exists and has a value use that as the component name
  if exists (select 1 from sysobjects where id = object_id('tAccpacComponentName') 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
      SELECT @ComponentName = ComponentName from tAccpacComponentName
  IF (@ComponentName is NULL)  
      -- get the component name from the custom table creation
      select @ComponentName = Bord_Component from Custom_Tables where Bord_Name = @EntityName
  -- if the component name is still null, use the entity name
  IF (@ComponentName is NULL)
  	set @ComponentName = @EntityName

  IF Len(@ComponentName ) > 20
  BEGIN
    SET @SQL = 'Error Creating Field: Component Name [' + @ComponentName + '] cannot be more than 20 chars.' 
    RAISERROR(@SQL,1,1)
    RETURN -1
  END
*/


	IF (@DBFieldType in ('text', 'ntext')) BEGIN
		SET @DBFieldType = 'varchar(max)'
		SET @DBFieldSize = NULL
	END



  -- correct the format of the type
  IF (@AccpacEntryType in (32, 51) )
  BEGIN
    SET @DBFieldType = @DBFieldType + '(24, 6)'
    SET @DBFieldSize = NULL
  END

  IF (@DBFieldSize IS NOT NULL)
    SET @DBFieldType = @DBFieldType + '('+convert(varchar, @DBFieldSize)+ ')'


  -- TODO: this section does not clean up old columns on default accpac entities like Company
  --       this should be added to uninstall
  -- create a new physical DB column
  DECLARE @IgnoreNull nchar(1)
  SET @IgnoreNull = NULL
  IF (@SkipColumnCreation IS NULL)
  BEGIN
    IF NOT EXISTS (Select 1 FROM Information_Schema.Columns Where Table_Name = @EntityName
            AND Column_Name = @FieldName)
    BEGIN
        SET @SQL = 'ALTER TABLE ' + @EntityName + ' ADD '  
    END
    ELSE
    BEGIN 
        SET @IgnoreNull = '1'
        IF (@DBFieldType in ('image'))
            SET @SQL = NULL
        ELSE
        BEGIN
        -- cannot change a key
        IF EXISTS (Select 1 from Information_Schema.Key_Column_Usage Where Table_Name = @EntityName
            AND Column_Name = @FieldName)
            SET @SQL = NULL
        ELSE
            SET @SQL = 'ALTER TABLE ' + @EntityName + ' ALTER COLUMN '  
        END
    END

    IF (@SQL IS NOT NULL)
    BEGIN
        SET @SQL = @SQL + @FieldName + ' ' + @DBFieldType 

		IF (@IsIdentity = 'Y') BEGIN
			SET @SQL = @SQL + ' IDENTITY(1,1) '
		END

        IF  (@IgnoreNull IS NULL) 
        BEGIN
            IF (@AllowNull IS NULL OR @AllowNull = '0' OR Lower(@AllowNull) = 'n')
            BEGIN
                SET @SQL = @SQL + ' NOT NULL '
                IF @DefaultValue IS NULL
                BEGIN
                    IF (@DBFieldType = 'int' OR @DBFieldType = 'numeric')
	                    SET @DefaultValue = ' -1 '
                    ELSE IF (@DBFieldType = 'datetime' OR @DBFieldType = 'date')
    	                SET @DefaultValue = ' ''01/01/1900'' '
                    ELSE
    	                SET @DefaultValue = ' '''' '
                END
            END
            IF (@DefaultValue IS NOT NULL)
            BEGIN
                SET @SQL = @SQL + ' DEFAULT ' + @DefaultValue
            END
        END

		PRINT @SQL
        EXEC (@SQL)
    END
  END
  -- create the custom edit entry 
  EXEC @NextId = crm_next_id 44 -- custom_edits key
  
  DECLARE @Colp_DataType int
  DECLARE @Colp_DataSize int
  
  SET @Colp_DataType = NULL
  SET @Colp_DataSize = NULL
 
  IF (@AccpacEntryType = 10 -- text
      or @AccpacEntryType = 12 -- Email
      or @AccpacEntryType = 13 -- Web Url
      or @AccpacEntryType = 28 -- Multiline select
      )
  BEGIN
    SET @Colp_DataType = 4
    SET @Colp_DataSize = @DBFieldSize
  END 
  ELSE IF (@AccpacEntryType = 11)-- multiline text 
  BEGIN
    SET @Colp_DataType = 7
    SET @Colp_DataSize = 21
  END 
  ELSE IF (@AccpacEntryType = 21)-- Selection
  BEGIN
    SET @Colp_DataType = 5
    SET @Colp_DataSize = 1
  END 
  ELSE IF (    @AccpacEntryType = 22 -- user
            or @AccpacEntryType = 23 -- team
            or @AccpacEntryType = 53 -- territory
            or @AccpacEntryType = 26 -- key
            or @AccpacEntryType = 31 -- integer
            or @AccpacEntryType = 56 -- advsearchselect
           )
  BEGIN
    SET @Colp_DataType = 5
    SET @Colp_DataSize = 21
  END 
  ELSE IF (@AccpacEntryType = 32)  -- numeric
  BEGIN
    SET @Colp_DataType = 6
    SET @Colp_DataSize = 21
  END 
  ELSE IF (@AccpacEntryType = 51)  -- currency
  BEGIN
    SET @Colp_DataType = 6
    SET @Colp_DataSize = 20
  END 
  ELSE IF (@AccpacEntryType = 41 -- datetime
           or @AccpacEntryType = 42 -- date
          )
  BEGIN
    SET @Colp_DataType = 2
    SET @Colp_DataSize = 21
  END 
  ELSE IF (@AccpacEntryType = 45) -- checkbox
  BEGIN
    SET @Colp_DataType = 4
    SET @Colp_DataSize = 1
  END 

       --Colp_SearchSQL, Colp_ssViewField, 
       --Colp_StartTime, Colp_EndTime, Colp_TiedFields, Colp_Restricted, 
  DECLARE @vNow varchar(50)
  SET @vNow = convert(varchar,@Now)
  DECLARE @colp_colpropsid int
  Select @colp_colpropsid = colp_colpropsid from Custom_Edits where RTrim(ColP_ColName) = RTrim(@FieldName)
  IF (@colp_colpropsid IS NULL)
  BEGIN

		DECLARE @CustomTableIDFK int
		SELECT @CustomTableIDFK = bord_tableid
		  FROM custom_tables
		 WHERE bord_name = @EntityName;


		IF (@CustomTableIDFK IS NULL) BEGIN
			SELECT @CustomTableIDFK = bord_tableid
			  FROM custom_tables
			 WHERE bord_name = '_undefined';
		END


    SET @SQL = 
      'INSERT INTO Custom_Edits '+
      '(ColP_ColPropsId, ColP_Entity, ColP_ColName, ColP_EntryType, ColP_DefaultType, '+
      ' ColP_DefaultValue, ColP_EntrySize, ColP_LookupFamily, ColP_LookupWidth, ColP_Required,'+
      ' ColP_AllowEdit, ColP_System, '+
      ' ColP_CreatedBy, ColP_CreatedDate, ColP_UpdatedBy,ColP_UpdatedDate,ColP_TimeStamp,'+
      ' ColP_Deleted, Colp_SearchDefaultValue, ColP_Component,'+ 
      ' ColP_DataType, ColP_DataSize,Colp_Multiple,ColP_CustomTableIDFK)'+
      ' VALUES '+
      ' (' +
       convert(varchar,@NextId)+', '+
       COALESCE('''' + @EntityName+'''','NULL')+ ', '+
       COALESCE('''' + @FieldName+'''','NULL')+ ', '+
       convert(varchar,@AccpacEntryType)+ ', 0, ' + 
       COALESCE('''' + Replace(@DefaultValue, '''', '''''') +'''','NULL')+ ', '+
       convert(varchar,@AccpacEntrySize)+', ' + 
       COALESCE('''' + @LookupFamily+'''','NULL')+ ', '+
       COALESCE('''' + @LookupWidth+'''','NULL')+ ', '+
       COALESCE('''' + @IsRequired+'''','NULL')+ ', '+
       COALESCE('''' + @AllowEdit+'''','NULL')+ ', '+
       COALESCE('''' + @SystemCol+'''','NULL')+ ', '+
       '-1, '+
       COALESCE('''' + @vNow+'''','NULL')+ ', '+
       '-1, '+
       COALESCE('''' + @vNow+'''','NULL')+ ', '+
       COALESCE('''' + @vNow+'''','NULL')+ ', '+
       'NULL, NULL, '+
       COALESCE('''' + @ComponentName+'''','NULL')+ ', '+
       convert(varchar,@Colp_DataType)+', '+ 
       convert(varchar,@Colp_DataSize)+', '+ 
       COALESCE('''' + @Multiple+'''','NULL') + ', ' + 
       convert(varchar,@CustomTableIDFK) + ')'
  END 
  ELSE
  BEGIN
    SET @SQL = 
      'UPDATE Custom_Edits SET '+
      'ColP_Entity = ' + COALESCE('''' + @EntityName+'''','NULL') + ', ' +
      'ColP_ColName = ' + COALESCE('''' + @FieldName+'''','NULL')+ ', '+ 
      'ColP_EntryType = '  + convert(varchar,@AccpacEntryType) +  ', '+
      'ColP_DefaultValue = ' + COALESCE('''' + REPLACE(@DefaultValue,'''','''''')+'''','NULL')+ ', '+ 
      'ColP_EntrySize = ' + convert(varchar,@AccpacEntrySize)+', ' +  
      'ColP_LookupFamily = ' + COALESCE('''' + @LookupFamily+'''','NULL')+ ', '+
      'ColP_LookupWidth = ' +  COALESCE('''' + @LookupWidth+'''','NULL')+ ', '+
      'ColP_Required = ' + COALESCE('''' + @IsRequired+'''','NULL')+ ', '+
      'ColP_AllowEdit = ' +  COALESCE('''' + @AllowEdit+'''','NULL')+ ', '+
      'ColP_System = ' +  COALESCE('''' + @SystemCol+'''','NULL')+ ', '+
      'ColP_UpdatedBy = -1, ' + 
      'ColP_UpdatedDate = ' + COALESCE('''' + @vNow+'''','NULL')+ ', '+
      'ColP_TimeStamp = ' + COALESCE('''' + @vNow+'''','NULL')+ ', '+
      'ColP_Component = ' + COALESCE('''' + @ComponentName+'''','NULL')+ ', '+ 
      'ColP_DataType = ' +  COALESCE(convert(varchar,@Colp_DataType), 'NULL') +', '+ 
      'ColP_DataSize = ' + COALESCE(convert(varchar,@Colp_DataSize), 'NULL') + ', ' + 
      'ColP_Multiple = ' + COALESCE('''' + @Multiple + '''', 'NULL') + ' ' + 
      ' WHERE ColP_ColPropsId = ' + convert(varchar,@colp_colpropsid)
  END
  EXEC (@SQL)
  
  -- create the custom caption entry
  EXEC @NextId = crm_next_id 39 -- custom captions key
  DELETE FROM Custom_Captions 
   where Capt_FamilyType = 'Tags' and Capt_Family = 'ColNames' and Capt_Code = @FieldName
  -- now insert the new record
  INSERT INTO Custom_Captions
      (Capt_CaptionId, Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_Order, 
       Capt_CreatedBy, Capt_CreatedDate, Capt_UpdatedBy, Capt_UpdatedDate,Capt_TimeStamp, 
       Capt_Component) 
    VALUES
      (@NextId, 'Tags' , 'ColNames', @FieldName, @Caption, 0, 
        -1, @Now, -1, @Now, @Now,
	@ComponentName)

  SET NOCOUNT OFF
     
END
GO

/*
 * Creates a Sage CRM select field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateSelectField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @LookupFamily_In nvarchar(30) = NULL,
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N',
  @SkipColumnCreation_In nchar(1) = NULL
 
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 21,
                             @AccpacEntrySize = 1,
                             @DBFieldType = 'nvarchar',
                             @DBFieldSize = 40,
                             @LookupFamily = @LookupFamily_In,  
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In,
                             @SkipColumnCreation = @SkipColumnCreation_In
END
GO


/*
 * Creates a Sage CRM text field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateTextField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AccpacEntrySize_In int = NULL,
  @DBFieldSize_In int = NULL,
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N',
  @DefaultValue_In nvarchar(255) = null

AS 
BEGIN
  if (@DBFieldSize_In is NULL)
    SET @DBFieldSize_In = @AccpacEntrySize_In

  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 10,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'varchar',
                             @DBFieldSize = @DBFieldSize_In,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In,
                             @DefaultValue = @DefaultValue_In

END
GO


/*
 * Creates a Sage CRM key integer id field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateKeyField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AccpacEntrySize_In int = 20, 
  @AllowNull_In nchar(1) = NULL,
  @IsRequired_In nchar(1) = 'Y', 
  @AllowEdit_In nchar(1) = NULL, 
  @IsUnique_In nchar(1) = 'Y'
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 26,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'int',
                             @LookupFamily = @EntityName_In,
                             @DBFieldSize = NULL,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In
END
GO


/*
 * Creates a Sage CRM key integer id field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateKeyIdentityField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AccpacEntrySize_In int = 20, 
  @AllowNull_In nchar(1) = NULL,
  @IsRequired_In nchar(1) = 'Y', 
  @AllowEdit_In nchar(1) = NULL, 
  @IsUnique_In nchar(1) = 'Y'
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 26,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'int',
                             @LookupFamily = @EntityName_In,
                             @DBFieldSize = NULL,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In,
                             @IsIdentity = 'Y'
END
GO


/*
 * Creates a Sage CRM integer field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateIntegerField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AccpacEntrySize_In int = 10,
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N'
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 31,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'int',
                             @DBFieldSize = NULL,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In
END
GO


/*
 * Creates a Sage CRM Numeric field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateNumericField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AccpacEntrySize_In int = 10,
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N'
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 32,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'numeric',
                             @DBFieldSize = NULL,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In
END
GO


/*
 * Creates a Sage CRM Currency field
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateCurrencyField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AccpacEntrySize_In int = 10,
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N'
AS 
BEGIN
  DECLARE @SQL varchar(300), @ComponentName varchar(50)
  DECLARE @NextId int
  exec usp_TravantCRM_GetInstallComponentName NULL, @ComponentName OUTPUT

  -- currency requires a special CRM field to represent the currency ID
  IF NOT EXISTS (Select 1 FROM Information_Schema.Columns Where Table_Name = @EntityName_In
            AND Column_Name = @FieldName_In)
  BEGIN
	  EXEC @NextId = crm_next_id 44 -- custom_edits key
	  SET @SQL= 'ALTER TABLE ' + @EntityName_In + ' ADD ' + @FieldName_In + '_CID INTEGER NULL '
	  EXEC (@SQL)

		DECLARE @CustomTableIDFK int
		SELECT @CustomTableIDFK = bord_tableid
		  FROM custom_tables
		 WHERE bord_name = @EntityName_In;



	  INSERT INTO Custom_Edits
		(ColP_ColName,ColP_Entity,ColP_EntryType,ColP_LookupFamily,
		 ColP_System,ColP_DataType,colp_CreatedDate,colp_TimeStamp,colp_UpdatedDate,
		 colp_Component,ColP_ColPropsId, ColP_CustomTableIDFK)  
	  VALUES (@FieldName_In + '_CID',@EntityName_In,21,N'CurrencySymbols',
		 N'Y',5,getDate(),getDate(),getDate(),
		 @ComponentName,@NextId, @CustomTableIDFK)

	  SET @SQL = 'UPDATE ' + @EntityName_In + ' SET ' + @FieldName_In + '_CID=1'
	  EXEC (@SQL)
  END
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 51,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'numeric',
                             @DBFieldSize = NULL,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In
END
GO


/*
 * Creates a Sage CRM Search Select field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateSearchSelectField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @LookupFamily_In nvarchar(30) = NULL, 
  @AccpacEntrySize_In int = 20,
  @SearchValue_In nvarchar(255) = '0', 
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N'
  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 26,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'int',
                             @DBFieldSize = NULL,
                             @LookupFamily = @LookupFamily_In,
                             @SearchValue = @SearchValue_In,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In
                               
END
GO


/*
 * Creates a Sage CRM Multiselect field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateMultiselectField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @LookupFamily_In nvarchar(30) = NULL, 
  @AccpacEntrySize_In int = 20,
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N'
  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 28,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'nvarchar',
                             @DBFieldSize = 255,
                             @LookupFamily = @LookupFamily_In,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In,
                             @Multiple = 'Y'
                               
END
GO


/*
 * Creates a Sage CRM User Select field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateUserSelectField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N'
  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 22,
                             @AccpacEntrySize = 0,
                             @DBFieldType = 'int',
                             @DBFieldSize = NULL,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In
                               
END
GO


/*
 * Creates a Sage CRM Adv Search Select field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateAdvSearchSelectField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @LookupFamily_In nvarchar(30) = NULL, 
  @SearchValue_In nvarchar(255) = NULL, 
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N',
  @AccpacEntrySize_In int = 20
  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 56,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'int',
                             @DBFieldSize = NULL,
                             @LookupFamily = @LookupFamily_In,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In,
                             @SearchValue = @SearchValue_In
                               
END
GO


/*
 * Creates a Sage CRM Checkbox field on an existing table
 */
CREATE OR ALTER PROCEDURE [dbo].[usp_TravantCRM_CreateCheckboxField]
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N',
  @DefaultValue_In nvarchar(255) = NULL
  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 45,
                             @AccpacEntrySize = 0,
                             @DBFieldType = 'nchar',
                             @DBFieldSize = 1,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In,
  			     @DefaultValue = @DefaultValue_In                               
END
GO


/*
 * Creates a Sage CRM datetime field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateDateTimeField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N',
  @DefaultValue nvarchar(255) = NULL
  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 41,
                             @AccpacEntrySize = 0,
                             @DBFieldType = 'datetime',
                             @DBFieldSize = NULL,
                             @DefaultValue = @DefaultValue,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In                               
END
GO


/*
 * Creates a Sage CRM date field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateDateField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N',
  @DefaultValue nvarchar(255) = NULL
  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 42,
                             @AccpacEntrySize = 0,
                             @DBFieldType = 'datetime',
                             @DBFieldSize = NULL,
                             @DefaultValue = @DefaultValue,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In                               
END
GO


/*
 * Creates a Sage CRM Email field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateEmailField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N',
  @AccpacEntrySize_In int = 50,
  @DBFieldSize_In int = 255
  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 12,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'nvarchar',
                             @DBFieldSize = @DBFieldSize_In,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In                               
END
GO


/*
 * Creates a Sage CRM URL field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateURLField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N',
  @AccpacEntrySize_In int = 50,
  @DBFieldSize_In int = 255
  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 13,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'nvarchar',
                             @DBFieldSize = @DBFieldSize_In,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In                               
END
GO


/*
 * Creates a Sage CRM Multiline Text field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateMultilineField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AccpacEntrySize_In int = 100,
  @LookupWidth_In nvarchar(15) = NULL,
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N'  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 11,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @LookupWidth = @LookupWidth_In,
                             @DBFieldType = 'ntext',
                             @DBFieldSize = NULL,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In                               
END
GO


/*
 * Creates a Sage CRM Team field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateTeamField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AccpacEntrySize_In int = 0,
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N'  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 23,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'int',
                             @DBFieldSize = NULL,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In                               
END
GO


/*
 * Creates a Sage CRM Territory field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateTerritoryField
  @EntityName_In nvarchar(40) = NULL, 
  @FieldName_In nvarchar(40) = NULL, 
  @Caption_In nvarchar(255) = NULL, 
  @AccpacEntrySize_In int = 0,
  @AllowNull_In nchar(1) = 'Y',
  @IsRequired_In nchar(1) = 'N', 
  @AllowEdit_In nchar(1) = 'Y', 
  @IsUnique_In nchar(1) = 'N'  
AS 
BEGIN
  exec usp_TravantCRM_CreateField @EntityName = @EntityName_In, 
                             @FieldName = @FieldName_In, 
                             @Caption = @Caption_In,
                             @AccpacEntryType = 53,
                             @AccpacEntrySize = @AccpacEntrySize_In,
                             @DBFieldType = 'int',
                             @DBFieldSize = NULL,
                             @AllowNull = @AllowNull_In,
                             @IsRequired = @IsRequired_In, 
                             @AllowEdit = @AllowEdit_In, 
                             @IsUnique = @IsUnique_In                               
END
GO


/*
 * Enulates the CreateTable Accpac call
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateTable
  @EntityName nvarchar(40) = NULL, 
  @ColPrefix nvarchar(10) = NULL,
  @IDField nvarchar(80) = NULL, 
  @IsPrimaryTable nchar(1) = NULL,
  @IsSystemTable nchar(1) = NULL,
  @IsHiddenTable nchar(1) = NULL,
  @ComponentName nvarchar(40) = NULL,
  @UseIdentityForKey nchar(1) = NULL
   
AS
BEGIN
  SET NOCOUNT ON
  -- the SQL to execute
  DECLARE @SQL nvarchar (4000)
  -- the table id
  DECLARE @TableId int 
  DECLARE @Now DateTime
  DECLARE @WorkflowField nvarchar (40)

  -- Create a consistent time
  SET @Now = getDate()

  IF (@ComponentName IS NULL)
  BEGIN
	exec usp_TravantCRM_GetInstallComponentName @EntityName, @ComponentName OUTPUT
  END
  -- Create the table
  if exists (select 1 from sysobjects where id = object_id(@EntityName) 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
  BEGIN
    Exec usp_TravantCRM_DropTable @EntityName
  END
  
  BEGIN

    -- create the physical table    
/* Added below using create field functions
	'['+@ColPrefix + '_CreatedBy] [int] NULL ,' +
	'['+@ColPrefix + '_CreatedDate] [datetime] NULL DEFAULT (getdate()),' +
	'['+@ColPrefix + '_UpdatedBy] [int] NULL ,' +
	'['+@ColPrefix + '_UpdatedDate] [datetime] NULL DEFAULT (getdate()),' +
	'['+@ColPrefix + '_TimeStamp] [datetime] NULL DEFAULT (getdate()),' +
*/

	DECLARE @IdentityClause varchar(25)
	SET @IdentityClause = ''
	IF (@UseIdentityForKey = 'Y') BEGIN
		SET @IdentityClause = ' IDENTITY(1,1) '
	END

    SET @SQL = 'CREATE TABLE dbo.' + @EntityName + '(' +
	'['+@IDField+ '] [int] NOT NULL ' + @IdentityClause + ',' +
	'['+@ColPrefix + '_Deleted] [int] NULL ,' +
	'['+@ColPrefix + '_WorkflowId] [int] NULL ,' +
	'['+@ColPrefix + '_Secterr] [int] NULL' + 
    ') ON [PRIMARY]'
    EXEC (@SQL)

	Print @SQL

    -- create the tables index
    SET @SQL = 'ALTER TABLE ' + @EntityName + ' WITH NOCHECK ADD '+
	 'PRIMARY KEY  CLUSTERED ( [' + @IDField + ']) ON [PRIMARY]' 
    EXEC (@SQL)
    -- get the next id for the table
    exec @TableId = crm_next_id 35 -- 35 is the id for tables
    -- create the custom_tables record for this entity
    -- set the "boolean" values
    if ( @IsPrimaryTable IS NULL OR rtrim(@IsPrimaryTable) = '' OR lOWER(@IsPrimaryTable) = 'n')
      set @IsPrimaryTable = NULL
    else 
      set @IsPrimaryTable = 'y'

    if ( @IsSystemTable IS NULL OR rtrim(@IsSystemTable) = '' OR lOWER(@IsSystemTable) = 'n')
      set @IsSystemTable = NULL
    else 
      set @IsSystemTable = 'y'

    if ( @IsHiddenTable IS NULL OR rtrim(@IsHiddenTable) = '' OR lOWER(@IsHiddenTable) = 'n')
      set @IsHiddenTable = NULL
    else 
      set @IsHiddenTable = 'y'

    -- set any string that will be used
    SET @WorkflowField = @ColPrefix + '_WorkflowId'
    insert into custom_tables 
       (Bord_TableId, Bord_Caption, Bord_System, Bord_Hidden, Bord_Name, Bord_Prefix, Bord_IdField,
        Bord_CreatedBy, Bord_CreatedDate, Bord_UpdatedBy, Bord_UpdatedDate, Bord_TimeStamp,
        Bord_PrimaryTable, Bord_Component, Bord_WorkflowIdField)
      VALUES 
       (@TableId, @EntityName, @IsSystemTable, @IsHiddenTable, @EntityName, @ColPrefix, @IDField,
        -1, @Now, -1, @Now, @Now,
        @IsPrimaryTable, @ComponentName, @WorkFlowField)

    -- create the custom id counter row for the table 
    INSERT INTO SQL_Identity Values (@TableId, 6000)

    -- Create the RepRanges entry
    INSERT INTO Rep_Ranges VALUES (@TableId, 6000, 6499, 6500, 6999, 7000)

    -- Add the default fields
    Declare @FieldName varchar(200)
    SET @FieldName = @ColPrefix + '_CreatedBy'
    exec usp_TravantCRM_CreateUserSelectField @EntityName, @FieldName, 'Created By'
    SET @FieldName = @ColPrefix + '_CreatedDate'
    exec usp_TravantCRM_CreateDateTimeField @EntityName, @FieldName, 'Created Date', 'Y', 'N', 'N', 'N', 'getDate()'
    SET @FieldName = @ColPrefix + '_UpdatedBy'
    exec usp_TravantCRM_CreateUserSelectField @EntityName, @FieldName, 'Updated By'
    SET @FieldName = @ColPrefix + '_UpdatedDate'
    exec usp_TravantCRM_CreateDateTimeField @EntityName, @FieldName, 'Updated Date', 'Y', 'N', 'N', 'N', 'getDate()'
    SET @FieldName = @ColPrefix + '_TimeStamp'
    exec usp_TravantCRM_CreateDateTimeField @EntityName, @FieldName, 'Timestamp', 'Y', 'N', 'N', 'N', 'getDate()'
    
  END

  SET NOCOUNT OFF
    
END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_DropView
  @ViewName_In nvarchar(40)
AS 
BEGIN
    SET NOCOUNT ON
    Declare @TableId int, @NextId int
    Declare @SQL varchar(8000)
    Declare @Now DateTime
    SET @Now = GetDate()

    -- remove the old view
    if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[' + @ViewName_In +']') 
            and OBJECTPROPERTY(id, N'IsView') = 1)
    BEGIN
        SET @SQL = 'drop view [dbo].['+@ViewName_In + ']'
		PRINT @SQL
        EXEC (@SQL)
    END
    
	DELETE FROM custom_tables 
	 WHERE bord_caption = @viewname_in      

    DELETE FROM Custom_Views 
           WHERE CuVi_ViewName = @ViewName_In
                 
END 
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_RegisterViewAsTable
  @ViewName_In nvarchar(40),
  @ComponentName_In nvarchar(40) = NULL 
AS
BEGIN
	DECLARE @TableId int, @NextId int
	DECLARE @Now DateTime
	SET @Now = getDate()

	IF (@ComponentName_In IS NULL)
		exec usp_TravantCRM_GetInstallComponentName NULL, @ComponentName_In OUTPUT

	select @TableId = bord_tableId from custom_tables where bord_name = 'Custom_Tables'
    exec @NextId = crm_next_id @TableId 
    insert into custom_tables
        (Bord_TableId, Bord_Caption, Bord_Name,
          Bord_CreatedBy, Bord_CreatedDate, 
          Bord_UpdatedBy, Bord_UpdatedDate, Bord_TimeStamp,
          Bord_Component
        )
        VALUES
        ( @NextId, @ViewName_In, @ViewName_In,
          -1, @Now, -1, @Now, @Now, 
          @ComponentName_In
        )
END
GO


/*
 * Creates a Sage CRM View
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateView
  @ViewName_In nvarchar(40), 
  @ViewScript_In varchar(max), 
  @Description_In nvarchar(40) = NULL,  
  @Options_In int = 0,
  @IdColumn nvarchar(50) = null,
  @SSViewFields nvarchar(200) = null, 
  @ComponentName_In nvarchar(40) = NULL,
  @EntityName_In nvarchar(40) = NULL
AS 
BEGIN
    SET NOCOUNT ON
    DECLARE @TableId int, @NextId int
    DECLARE @SQL varchar(max)
    DECLARE @Now DateTime = GetDate()
    
	IF EXISTS (SELECT 'x' FROM Custom_Views WHERE CuVi_ViewName = @ViewName_In) BEGIN

		IF EXISTS(SELECT 'x' FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME=@ViewName_In) BEGIN
			SET @SQL = REPLACE(@ViewScript_In, 'CREATE VIEW', 'ALTER VIEW')
			--PRINT @SQL
			EXEC (@SQL)

			UPDATE Custom_Views
			   SET CuVi_ViewScript = @ViewScript_In,
			       --CuVi_SqliteScript = @ViewScript_In,
				   CuVi_Options = @Options_In,
				   CuVi_Description = @Description_In,
				   CuVi_UpdatedDate = @Now
			 WHERE CuVi_ViewName = @ViewName_In;
		END ELSE BEGIN 
			--PRINT @ViewScript_In
			EXEC (@ViewScript_In)
		END
	END ELSE BEGIN

		-- remove the old view
		--EXEC usp_TravantCRM_DropView @ViewName_In
                 
		-- Add the new view
		IF (@ComponentName_In IS NULL)
			exec usp_TravantCRM_GetInstallComponentName @EntityName_In, @ComponentName_In OUTPUT


		DECLARE @CustomTableIDFK int
		SELECT @CustomTableIDFK = bord_tableid
		  FROM custom_tables
		 WHERE bord_name = @EntityName_In;


		IF (@CustomTableIDFK IS NULL) BEGIN
			SELECT @CustomTableIDFK = bord_tableid
			  FROM custom_tables
			 WHERE bord_name = '_undefined';
		END


		select @TableId = bord_tableId from custom_tables where bord_name = 'Custom_Views'
		exec @NextId = crm_next_id @TableId 
		EXEC (@ViewScript_In)
		INSERT INTO Custom_Views
			( CuVi_ViewID, CuVi_CreatedBy, CuVi_CreatedDate, CuVi_UpdatedBy, CuVi_UpdatedDate, CuVi_TimeStamp, CuVi_Deleted, CuVi_Secterr,
			  CuVi_ViewName, CuVi_Entity, CuVi_Description, CuVi_ViewScript,
			  CuVi_Options, CuVi_Component, cuvi_CustomTableIDFK
			)
			VALUES
			( @NextId, -1, @Now, -1, @Now, @Now, NULL, NULL, 
			  @ViewName_In, @EntityName_In, @Description_In, @ViewScript_In,
			  @Options_In, @ComponentName_In, @CustomTableIDFK
			)
		-- Also make an entry in the custom_tables entry to allow this view to be used for screen displays
		-- just like a table can be; on caveat, you must do "custom" saves on the field values
		EXEC usp_TravantCRM_RegisterViewAsTable @ViewName_In, @ComponentName_In 


		-- if @IdColumn and @SSViewFields are specified, set these values for the Search Select Advanced functionality
		if (@IdColumn is not null and @SSViewFields is not null)
		begin
			-- @NextId will still be set to the custom_table id
			update custom_tables set bord_IdField = @IdColumn where bord_tableid = @NextId
			-- now make the custom captions entry for what will show in the SS dropdown results
			declare @capt_NextId int
			exec usp_getNextId 'custom_captions', @capt_NextId output
			delete from custom_captions where capt_Family = 'SS_ViewFields' and capt_code = @ViewName_In
			INSERT INTO CUSTOM_CAPTIONS 
				(capt_CaptionId, capt_FamilyType, capt_Family, capt_Code, capt_US, capt_Component) 
			VALUES 
				(@capt_NextId, 'Tags', 'SS_ViewFields',	@ViewName_In, @SSViewFields, @ComponentName_In)

		end
	END    
    SET NOCOUNT OFF
        
END
GO


/*
 * Creates an Dropdown value for an accpac select field
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_CreateDropdownValue
  @Capt_Family_In nvarchar(40) = NULL, 
  @Capt_Code_In nvarchar(40) = NULL, 
  @Capt_Order_In int = NULL,  
  @Capt_US_In nvarchar(max) = NULL, 
  @Capt_ES_In nvarchar(max) = NULL, 
  @Capt_Component_In nvarchar(40) = NULL 
AS 
BEGIN
    SET NOCOUNT ON
    Declare @NextId int
    Declare @SQL varchar(8000)
    Declare @Now DateTime
    SET @Now = GetDate()
	IF (@Capt_Component_In IS NULL)
		exec usp_TravantCRM_GetInstallComponentName NULL, @Capt_Component_In OUTPUT

    -- get the next custom_caption id
    exec @NextId = crm_next_id 39
    INSERT INTO Custom_Captions 
        (Capt_CaptionId, Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_ES, Capt_Order,
         Capt_CreatedBy, Capt_CreatedDate, Capt_UpdatedBy, Capt_UpdatedDate, Capt_TimeStamp, 
         Capt_Component
        )
    Values
        (@NextId, 'Choices', @Capt_Family_In, @Capt_Code_In, @Capt_Us_In, @Capt_ES_In, @Capt_Order_In,
         -1, @Now, -1, @Now, @Now, @Capt_Component_In
        )
    SET NOCOUNT OFF
END
GO

/*
 * Drops an accpac table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_DropTable
  @TableName nvarchar(40)  
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @SQL varchar(8000)
  DECLARE @TableId int
  
  SELECT @TableId = bord_TableId from custom_tables where bord_Name = @TableName

  -- delete the custom caption entries for any columns
  DELETE FROM Custom_Captions WHERE capt_family = @TableName OR capt_code = @TableName 

  -- delete the custom caption entries for any columns
  DELETE FROM Custom_Captions WHERE Capt_Code in (SELECT colp_ColName from  custom_edits where colp_Entity = @TableName)

  -- delete any custom screen objects tied to the entity
  DELETE FROM Custom_ScreenObjects where cobj_EntityName  = @TableName

  -- delete any custom screen entries
  DELETE Custom_Screens WHERE Seap_ColName in (SELECT colp_ColName from  custom_edits where colp_Entity = @TableName)

  -- delete any custom list entries
  DELETE Custom_Lists WHERE grip_ColName in (SELECT colp_ColName from  custom_edits where colp_Entity = @TableName)

  -- remove the columns from custom_edits
  DELETE FROM Custom_Edits where colp_Entity = @TableName
  
  DELETE FROM Rep_Ranges where range_TableId = @TableId
  DELETE FROM SQL_Identity where id_TableId = @TableId

  DELETE FROM custom_tables where bord_tableId = @TableId
  
  if exists (select 1 from sysobjects where id = object_id(@TableName) 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		EXEC ('DROP TABLE ' + @TableName)

  SET NOCOUNT OFF
     
END
GO


/*
 * Drops an accpac field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_DropField
  @TableName nvarchar(40) = NULL, 
  @FieldName nvarchar(40) = NULL 
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @SQL varchar(8000)

    
  -- delete the custom caption entry
  DELETE Custom_Captions WHERE Capt_Code = @FieldName

  -- delete any custom screen entries
  DELETE Custom_Screens WHERE Seap_ColName = @FieldName

  -- delete any custom list entries
  DELETE Custom_Lists WHERE grip_ColName = @FieldName
  
  -- Delete this last due to foreign keys
  DELETE Custom_Edits where RTrim(ColP_ColName) = RTrim(@FieldName)

  -- drop the field
	if exists(select 1 from information_schema.columns where table_name = @TableName AND column_name = @FieldName)
	begin 
	  SET @SQL = 'ALTER TABLE ' + @TableName + ' DROP COLUMN ' + @FieldName 
	  EXEC (@SQL)
	end  

  SET NOCOUNT OFF
     
END
GO


/*
 * Renames an accpac field on an existing table
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_RenameField
  @TableName nvarchar(40), 
  @FieldName_From nvarchar(40),
  @FieldName_To nvarchar(40),
  @Caption_In nvarchar(255) = null
AS
BEGIN
	--SET NOCOUNT ON
	declare @From varchar(255), @To varchar(255)
	SELECT @From = '['+ @TableName+ '].' + @FieldName_From , @To =  @FieldName_To 
	-- Verify that the table currently exists in the table
	if exists(select 1 from information_schema.columns where table_name = @TableName AND column_name = @FieldName_From)
	begin 
		-- EXEC sp_rename is going to generate the following message to the screen...
		-- "Caution: Changing any part of an object name could break scripts and stored procedures."
		-- give the user more details
		PRINT 'usp_TravantCRM_RenameField: Renaming ' + @From + ' to ' + @To
		EXEC sp_rename @From, @To, 'COLUMN'
		UPDATE custom_edits SET colp_Colname = @FieldName_To  where colp_Colname = @FieldName_From

		IF (@Caption_In IS NULL) BEGIN
			UPDATE custom_captions SET capt_code = @FieldName_To WHERE capt_code = @FieldName_From;
		END ELSE BEGIN
			UPDATE custom_captions SET capt_code = @FieldName_To, capt_us = @Caption_In WHERE capt_code = @FieldName_From;
		END

	end
	else
		PRINT 'Warning *** usp_TravantCRM_RenameField: ' + @From + ' does not exist.'
END
GO


/*
 * Displays the definition of a Sage CRM block
 */
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_GetBlockInfo
  @ObjectName varchar(50)
AS
BEGIN

	DECLARE @ScreenType varchar(40)
	
	SELECT @ScreenType = cobj_Type
	  FROM custom_screenobjects 
	 WHERE cobj_name = @ObjectName;


	SELECT * 
	  FROM custom_screenobjects 
	 WHERE cobj_name = @ObjectName


	IF (@ScreenType = 'List') BEGIN

		SELECT * 
		  FROM custom_lists 
		 WHERE grip_gridname=@ObjectName
	  ORDER BY grip_order;

	END ELSE BEGIN

		SELECT *
		  FROM custom_screens
		 WHERE seap_SearchBoxName = @ObjectName
	  ORDER BY seap_order;

	END
END
Go