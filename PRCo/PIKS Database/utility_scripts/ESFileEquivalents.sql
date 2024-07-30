/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2020

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_GetInstallComponentName 
  @EntityName nvarchar(40),
  @ComponentName nvarchar(200) OUTPUT
AS
BEGIN
	-- always return 'PRCo'
	SET @ComponentName = 'PRCo'
/*
  DECLARE @SQL varchar(8000)
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
    SET @SQL = 'ufn_AccpacGetInstallComponentName: Error Retrieving Component: Component Name [' + @ComponentName + '] cannot be more than 20 chars.' 
    RAISERROR(@SQL,16,1)
  END
*/
END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_DeleteCustom_Caption
  @FamilyType nvarchar(12) = NULL , 
  @Family nvarchar(30) = NULL , 
  @Code nvarchar(40)= NULL 
AS 
BEGIN
	DECLARE @Where varchar(200)
	if (@FamilyType IS NOT NULL)
		SET @Where = ' capt_FamilyType = ''' + @FamilyType + ''' '
	if (@Family IS NOT NULL)
		SET @Where = COALESCE(@Where + ' and ', '') + ' capt_Family = ''' + @Family + ''' ' 
	if (@Code IS NOT NULL)
		SET @Where = COALESCE(@Where + ' and ', '') + ' capt_Code = ''' + @Code + ''' ' 
	if (@Where is not null)	
		exec ('DELETE from Custom_Captions where ' + @Where)
	else begin
		DECLARE @MSG varchar(200)
		SET @MSG = 'ERROR: usp_TravantCRM_DeleteCustom_Captions: This function cannot be used to remove all custom_captions values.' 
		RAISERROR(@MSG,16,1)
				 
	end
END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_DeleteCustom_Tab
  @Entity nvarchar(40), 
  @Caption nvarchar(40) = NULL 
AS 
BEGIN
	if (@Caption is not null)
		DELETE from Custom_Tabs where tabs_Entity = @Entity and tabs_Caption = @Caption
	else
		DELETE from Custom_Tabs where tabs_Entity = @Entity
END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_DeleteCustom_List
  @GridName nvarchar(40), 
  @ColName nvarchar(40) = NULL  
AS 
BEGIN
	if (@ColName is not null)
		DELETE from Custom_Lists where grip_GridName = @GridName and grip_ColName = @ColName
	else
		DELETE from Custom_Lists where grip_GridName = @GridName 
END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_DeleteCustom_Screen
  @SearchBoxName nvarchar(40), 
  @ColName nvarchar(40) = NULL  
AS 
BEGIN
	if (@ColName is not null)
		DELETE from Custom_Screens where seap_SearchBoxName = @SearchBoxName and seap_ColName = @ColName
	else
		DELETE from Custom_Screens where seap_SearchBoxName = @SearchBoxName 
END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_DeleteCustom_ScreenObject
  @Name nvarchar(40)
AS 
BEGIN
	exec usp_TravantCRM_DeleteCustom_Screen @Name
	exec usp_TravantCRM_DeleteCustom_List @Name
	DELETE from Custom_ScreenObjects where cobj_Name = @Name 
END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_AddCustom_ScreenObjects
  @Name nvarchar(40), 
  @Type nvarchar(40), 
  @EntityName nvarchar(40), 
  @AllowDelete nchar(1) = NULL,
  @Deleted tinyint = null,
  @TargetTable nvarchar(40) = NULL, 
  @Properties ntext = NULL, 
  @CustomContent ntext = NULL,  
  @UseEntity nvarchar(40) = NULL, 
  @TargetList nvarchar(50) = NULL, 
  @Ftable nvarchar(50) = NULL,
  @FtableFCol nvarchar(50) = NULL
AS 
BEGIN
	DECLARE @Now datetime
	DECLARE @bord_TableId int
	DECLARE @NextId int, @cobj_TableId int -- only one of these get used
	DECLARE @ComponentName nvarchar(200)
	DECLARE @MSG varchar(8000)
	
	SET @Now = getDate()

	exec usp_TravantCRM_GetInstallComponentName @EntityName, @ComponentName OUTPUT
	Select @cobj_TableId = cobj_TableId 
      from Custom_ScreenObjects 
     where CObj_Name = @Name and  CObj_EntityName = @EntityName
	
	if (@cobj_TableId is Null) begin
		SELECT @bord_TableId = Bord_TableId FROM Custom_Tables WHERE Bord_Caption = N'Custom_ScreenObjects' AND Bord_Deleted IS NULL
	    exec @NextId = crm_next_id @bord_TableId
	end

	if (@AllowDelete = '') SET @AllowDelete = NULL
	if (@Deleted = '') SET @Deleted = NULL
	if (@TargetTable = '') SET @TargetTable = NULL
	if (cast(@Properties as varchar) = '') SET @Properties = NULL
	if (cast(@CustomContent as varchar) = '') SET @CustomContent = NULL
	if (@UseEntity = '') SET @UseEntity = NULL
	if (@TargetList = '') SET @TargetList = NULL
	if (@Ftable = '') SET @Ftable = NULL
	if (@FtableFCol = '') SET @FtableFCol = NULL


	IF (@ComponentName IS NULL) BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_ScreenObjects: Component Name could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	IF (@cobj_TableId is null and (@NextId IS NULL OR @NextId <= 0) )BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_ScreenObjects: Next ID could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	IF (@cobj_TableId is null) BEGIN

		DECLARE @CustomTableIDFK int
		SELECT @CustomTableIDFK = bord_tableid
		  FROM custom_tables
		 WHERE bord_name = @EntityName;


		IF (@CustomTableIDFK IS NULL) BEGIN
			SELECT @CustomTableIDFK = bord_tableid
			  FROM custom_tables
			 WHERE bord_name = '_undefined';
		END

		INSERT INTO Custom_ScreenObjects
			   (CObj_Name,CObj_Type,CObj_EntityName,CObj_AllowDelete,CObj_TargetTable,CObj_Properties,CObj_CustomContent,CObj_UseEntity,CObj_TargetList,Cobj_FTable,Cobj_FTableFCol,
				cobj_CreatedBy,cobj_CreatedDate,cobj_UpdatedBy,cobj_TimeStamp,cobj_UpdatedDate,cobj_Component,Cobj_TableID, CObj_CustomTableIDFK)  
		VALUES (@Name,@Type,@EntityName,@AllowDelete,@TargetTable,@Properties,@CustomContent,@UseEntity,@TargetList,@Ftable,@FtableFCol,
				-1,@Now,-1,@Now,@Now,@ComponentName,@NextId,@CustomTableIDFK)
	END ELSE BEGIN
		UPDATE Custom_ScreenObjects 
		   SET	CObj_Type=@Type, CObj_AllowDelete=@AllowDelete, CObj_Deleted=@Deleted,
				CObj_TargetTable=@TargetTable, CObj_Properties=@Properties,
				CObj_CustomContent=@CustomContent, CObj_UseEntity=@UseEntity,
				CObj_TargetList=@TargetList, Cobj_FTable=@Ftable, Cobj_FTableFCol=@FtableFCol,
				cobj_UpdatedBy=-1, cobj_TimeStamp=@Now, cobj_UpdatedDate=@Now,
				cobj_Component=@ComponentName
		 WHERE (CObj_TableId=@cobj_TableId)
	END
	
END
GO

/*
	NOTE:  For simplicity, this function deletes any existing Custom_Screen entry
			with a matching SearchBoxName and ColName, and readds it using the 
			provided values
*/
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_AddCustom_Screens
  @SearchBoxName nvarchar(40) , 
  @Order int , 
  @ColName nvarchar(40) , 
  @NewLine int = null,
  @RowSpan int = null,
  @ColSpan int = null, 
  @Required nchar(1) = null, 
  @DeviceId int = null,  
  @OnChangeScript ntext = null, 
  @ValidateScript ntext = null, 
  @CreateScript ntext = null
AS 
BEGIN
	
	DECLARE @Now datetime
	DECLARE @bord_TableId int
	DECLARE @NextId int, @seap_SearchEntryPropsID int -- only one of these get used
	DECLARE @ComponentName nvarchar(200)
	DECLARE @MSG varchar(8000)
	
	SET @Now = getDate()


	if (@NewLine IS NULL) SET @NewLine = 0
	if (@RowSpan IS NULL) SET @RowSpan = 1
	if (@ColSpan IS NULL) SET @ColSpan = 1
	if (@Required IS NULL or @Required = '') SET @Required = 'N'
	if (@DeviceId = 0) SET @DeviceId = NULL
	if (cast(@OnChangeScript as varchar) = '') SET @OnChangeScript = NULL
	if (cast(@ValidateScript as varchar) = '') SET @ValidateScript = NULL
	if (cast(@CreateScript as varchar) = '') SET @CreateScript = NULL

	exec usp_TravantCRM_GetInstallComponentName NULL, @ComponentName OUTPUT
	DELETE 
	  from Custom_Screens 
	 where seap_SearchBoxName = @SearchBoxName and seap_ColName = @ColName and IsNull(SeaP_DeviceID,'') = IsNull(@DeviceId,'')

	SELECT @bord_TableId = Bord_TableId FROM Custom_Tables WHERE Bord_Caption = N'Custom_Screens' AND Bord_Deleted IS NULL
    exec @NextId = crm_next_id @bord_TableId

	IF (@ComponentName IS NULL) BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_Screens: Component Name could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	IF (@NextId IS NULL OR @NextId <= 0 )BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_Screens: Next ID could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	DECLARE @CustomTableIDFK int
	SELECT @CustomTableIDFK = CObj_TableId
		FROM Custom_ScreenObjects
		WHERE CObj_Name = @SearchBoxName;


	IF (@CustomTableIDFK IS NULL) BEGIN
		SELECT @CustomTableIDFK = CObj_TableId
			FROM Custom_ScreenObjects
			WHERE CObj_Name = '_undefined';
	END

	INSERT INTO Custom_Screens
			(SeaP_SearchEntryPropsID,SeaP_SearchBoxName,SeaP_Order,SeaP_ColName,SeaP_Newline,SeaP_RowSpan,SeaP_ColSpan,SeaP_Required,
			 seap_CreatedBy,seap_CreatedDate,seap_UpdatedBy,seap_TimeStamp,seap_UpdatedDate,
			 seap_Component,SeaP_OnChangeScript,SeaP_ValidateScript,SeaP_CreateScript,SeaP_DeviceID, SeaP_ScreenObjectsIDFK)  
	VALUES	(@NextId,@SearchBoxName,@Order,@ColName,@NewLine,@RowSpan,@ColSpan,@Required,
			 -1,@Now,-1,@Now,@Now,
			 @ComponentName,@OnChangeScript,@ValidateScript,@CreateScript,@DeviceId, @CustomTableIDFK)

END
GO


/*
	NOTE:  For simplicity, this function deletes any existing Custom_Screen entry
			with a matching SearchBoxName and ColName, and readds it using the 
			provided values
		   This function also correctly handles setting values when ShowSelectAsGif is 'Y';
			the standard accpac es call does not.	
*/
CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_AddCustom_Lists
  @GridName nvarchar(40) , 
  @Order int , 
  @ColName nvarchar(40) , 
  @AllowRemove nvarchar(15) = null,
  @AllowOrderBy nvarchar(15) = null,
  @OrderByDesc nvarchar(15) = null, 
  @Alignment nvarchar(15) = null, 
  @Jump nvarchar(15) = null,  
  @ShowHeading nvarchar(15) = null, 
  @ShowSelectAsGif nvarchar(15) = null, 
  @CustomAction nvarchar(128) = null, 
  @CustomIdField nvarchar(64) = null, 
  @DeviceId int = null, 
  @CreateScript ntext = null,
  @CustomFunction nvarchar(200) = null,
  @DefaultOrderBy nvarchar(14) = null
AS 
BEGIN
	DECLARE @Now datetime
	DECLARE @bord_TableId int
	DECLARE @NextId int, @grip_GridPropsID int 
	DECLARE @ComponentName nvarchar(200)
	DECLARE @MSG varchar(8000)
	
	DECLARE @ViewMode varchar(10)

	SET @Now = getDate()

	if (@AllowRemove = '') SET @AllowRemove = NULL
	if (@AllowOrderBy = '') SET @AllowOrderBy = NULL
	if (@OrderByDesc = '') SET @OrderByDesc = NULL
	if (@Alignment = '') SET @Alignment = NULL
	if (@Jump = '') SET @Jump = NULL
	if (@ShowHeading = '') SET @ShowHeading = NULL
	if (@ShowSelectAsGif = '') begin
		SET @ShowSelectAsGif = NULL
		SET @ViewMode = NULL
	end else if (@ShowSelectAsGif = 'Y') begin
		SET @ShowSelectAsGif = NULL
		SET @ViewMode = 'GIF'
	end
	if (@CustomAction = '') SET @CustomAction = NULL
	if (@CustomIdField = '') SET @CustomIdField = NULL
	if (@DeviceId = 0) SET @DeviceId = NULL
	if (cast(@CreateScript as varchar) = '') SET @CreateScript = NULL

	exec usp_TravantCRM_GetInstallComponentName NULL, @ComponentName OUTPUT
	DELETE 
	  from Custom_Lists 
	 where grip_GridName = @GridName and grip_ColName = @ColName and IsNull(grip_DeviceID,'') = IsNull(@DeviceId,'')

	SELECT @bord_TableId = Bord_TableId FROM Custom_Tables WHERE Bord_Caption = N'Custom_Lists' AND Bord_Deleted IS NULL
    exec @NextId = crm_next_id @bord_TableId

	IF (@ComponentName IS NULL) BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_Lists: Component Name could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	IF (@NextId IS NULL OR @NextId <= 0 )BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_Lists: Next ID could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	DECLARE @CustomTableIDFK int
	SELECT @CustomTableIDFK = CObj_TableId
		FROM Custom_ScreenObjects
		WHERE cobj_name = @GridName;

	IF (@CustomTableIDFK IS NULL) BEGIN
		SELECT @CustomTableIDFK = CObj_TableId
			FROM Custom_ScreenObjects
			WHERE cobj_name = '_undefined';
	END


	INSERT INTO Custom_Lists
			(GriP_GridPropsID,GriP_GridName,GriP_Order,GriP_ColName,GriP_AllowRemove,GriP_AllowOrderBy,
			 GriP_OrderByDesc,GriP_Alignment,GriP_Jump,GriP_ShowHeading,Grip_ShowSelectAsGif,GriP_ViewMode,
			 GriP_CustomAction,GriP_CustomIdField,grip_CreatedBy,grip_CreatedDate,
			 grip_UpdatedBy,grip_TimeStamp,grip_UpdatedDate,grip_Component,Grip_CreateScript,GriP_DeviceID, GriP_ScreenObjectsIDFK,
			 GriP_CustomFunction, GriP_DefaultOrderBy)  
	VALUES	(@NextId,@GridName,@Order,@ColName,@AllowRemove,@AllowOrderBy,
			 @OrderByDesc,@Alignment,@Jump,@ShowHeading,@ShowSelectAsGif, @ViewMode,
			 @CustomAction,@CustomIdField,-1,@Now,
			 -1,@Now,@Now,@ComponentName,@CreateScript,@DeviceId, @CustomTableIDFK,
			 @CustomFunction, @DefaultOrderBy)

END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_AddCustom_Captions
  @FamilyType nvarchar(12) , 
  @Family nvarchar(30) , 
  @Code nvarchar(40) , 
  @Order int , 
  @US varchar(max) = null,
  @UK varchar(max) = null,
  @FR varchar(max) = null,
  @DE varchar(max) = null,
  @ES varchar(max) = null,
  @DU varchar(max) = null,
  @JP varchar(max) = null,
  @ComponentName nvarchar(40) = null
AS 
BEGIN
	DECLARE @Now datetime
	DECLARE @bord_TableId int
	DECLARE @NextId int 
	DECLARE @MSG varchar(8000)
	
	DECLARE @ViewMode varchar(10)

	SET @Now = getDate()

	IF (@ComponentName is null)
		exec usp_TravantCRM_GetInstallComponentName NULL, @ComponentName OUTPUT
	
	IF (@ComponentName IS NULL) BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_Captions: Component Name could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	exec usp_TravantCRM_DeleteCustom_Caption @FamilyType, @Family, @Code

	SELECT @bord_TableId = Bord_TableId FROM Custom_Tables WHERE Bord_Caption = N'Custom_Captions' AND Bord_Deleted IS NULL
    exec @NextId = crm_next_id @bord_TableId

	IF (@NextId IS NULL OR @NextId <= 0 )BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_Captions: Next ID could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	INSERT INTO Custom_Captions
			(capt_CaptionId,capt_FamilyType,capt_Family,capt_Code,capt_Order,
			 capt_US,capt_UK,capt_FR,capt_DE,capt_ES,capt_DU,capt_JP,
			 capt_CreatedBy,capt_CreatedDate,capt_UpdatedBy,capt_TimeStamp,capt_UpdatedDate,capt_Component)  
	VALUES	(@NextId,@FamilyType,@Family,@Code,@Order,
			 @US,@UK,@FR,@DE,@ES,@DU,@JP,
			-1,@Now,-1,@Now,@Now,@ComponentName)

END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_AddCustom_Tabs
  @Order int , 
  @Entity nvarchar(40),
  @Caption nvarchar(40),
  @Action nvarchar(40) ,
  @CustomFileName nvarchar(128) = null,
  @WhereSQL ntext = null,
  @Bitmap nvarchar(40) = null,
  @DeviceId int = null 
AS 
BEGIN
	DECLARE @Now datetime
	DECLARE @bord_TableId int
	DECLARE @NextId int 
	DECLARE @ComponentName nvarchar(200)
	DECLARE @MSG varchar(8000)

	SET @Now = getDate()

	exec usp_TravantCRM_GetInstallComponentName NULL, @ComponentName OUTPUT
	
	exec usp_TravantCRM_DeleteCustom_Tab @Entity, @Caption

	SELECT @bord_TableId = Bord_TableId FROM Custom_Tables WHERE Bord_Caption = N'Custom_Tabs' AND Bord_Deleted IS NULL
    exec @NextId = crm_next_id @bord_TableId

	IF (@ComponentName IS NULL) BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_Tabs: Component Name could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	IF (@NextId IS NULL OR @NextId <= 0 )BEGIN
		SET @MSG = 'usp_TravantCRM_AddCustom_Tabs: Next ID could not be determined.' 
		RAISERROR(@MSG,16,1)
	END

	IF (@Action = '') BEGIN
		SET @MSG = '\nusp_TravantCRM_AddCustom_Tabs: An empty Action value is invalid.  This will cause problems within Accpac CRM. Entity: '+ @Entity + ' Caption: ' + @Caption + '.' 
		PRINT @MSG
	END

	if (@CustomFileName = '') SET @CustomFileName = NULL
	if (@Bitmap = '') SET @Bitmap = NULL
	if (@DeviceId = 0) SET @DeviceId = NULL
	if (cast(@WhereSQL as varchar) = '') SET @WhereSQL = NULL

	DECLARE @CustomTableIDFK int
	SELECT @CustomTableIDFK = CObj_TableId
		FROM Custom_ScreenObjects
		WHERE cobj_Type = 'TabGroup'
		  AND CObj_Name = @Entity;

	INSERT INTO Custom_Tabs
		(Tabs_TabID,Tabs_Permission,Tabs_Perlevel,Tabs_Entity,Tabs_Caption,Tabs_Order,Tabs_Action,
		 Tabs_Customfilename,Tabs_WhereSQL,Tabs_Bitmap,
		 tabs_CreatedBy,tabs_CreatedDate,tabs_UpdatedBy,tabs_TimeStamp,tabs_UpdatedDate,tabs_Component,Tabs_DeviceID,
		 Tabs_ScreenObjectsIDFK)  
	VALUES	
		(@NextId,0,0,@Entity,@Caption,@Order,@Action,@CustomFileName,@WhereSQL,@Bitmap,
		-1,@Now,-1,@Now,@Now,@ComponentName,@DeviceId, 
		@CustomTableIDFK)

END
GO


CREATE OR ALTER PROCEDURE dbo.usp_TravantCRM_DefineCaptions
	@EntityName nvarchar(30), 
	@EntityCaption nvarchar(255), 
	@EntityCaptionPlural nvarchar(255), 
	@NameField nvarchar(40), 
	@IdField nvarchar(40), 
	@ProgressEntityName nvarchar(30), 
	@ProgressIdField nvarchar(40) 
AS 
BEGIN
	Declare @Temp varchar(500)   
	-- Main entity search results
	SET @Temp = 'No ' + @EntityCaptionPlural
	exec usp_TravantCRM_AddCustom_Captions 'Tags', @EntityName, 'NoRecordsFound', 0, @Temp 
	exec usp_TravantCRM_AddCustom_Captions 'Tags', @EntityName, 'RecordsFound', 0, @EntityCaptionPlural
	exec usp_TravantCRM_AddCustom_Captions 'Tags', @EntityName, 'RecordFound', 0, @EntityCaption

	-- SS Captions -- REQUIRED
	exec usp_TravantCRM_AddCustom_Captions 'Tags', 'SS_ViewFields', @EntityName, 0, @NameField
	exec usp_TravantCRM_AddCustom_Captions 'Tags', 'SS_idfields', @EntityName, 0, @IdField
	exec usp_TravantCRM_AddCustom_Captions 'Tags', 'SS_Entities', @EntityName, 0, @EntityName

	-- Progress Entity SS Captions
	if (@ProgressEntityName != '') begin
		exec usp_TravantCRM_AddCustom_Captions 'Tags', 'SS_idfields', @ProgressEntityName, 0, @ProgressIdField
		exec usp_TravantCRM_AddCustom_Captions 'Tags', 'SS_Entities', @ProgressEntityName, 0, @ProgressEntityName
		exec usp_TravantCRM_AddCustom_Captions 'Tags', 'SS_SearchTables', @ProgressEntityName, 0, @ProgressEntityName
	end

	-- Define key fields
	exec usp_TravantCRM_AddCustom_Captions 'Tags', @EntityName, @EntityName, 0, @EntityCaption
	exec usp_TravantCRM_AddCustom_Captions 'Tags', @EntityName, 'NameColumn', 0, @NameField
	exec usp_TravantCRM_AddCustom_Captions 'Tags', @EntityName, 'IdColumn', 0, @IdField
	SET @Temp = @EntityName + '.asp'
	exec usp_TravantCRM_AddCustom_Captions 'Tags', @EntityName, 'SummaryPage', 0, @Temp
END
Go