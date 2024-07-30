
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vDefaultConstraint]') 
            and OBJECTPROPERTY(id, N'IsView') = 1)
drop View [dbo].[vDefaultConstraint]
GO
create view dbo.vDefaultConstraint
as
select	
	c_obj.id 			    as CONSTRAINT_ID
    ,db_name()			    as CONSTRAINT_CATALOG
	,t_obj.name 			as TABLE_NAME
	,user_name(c_obj.uid)	as CONSTRAINT_SCHEMA
	,c_obj.name				as CONSTRAINT_NAME
	,col.name				as COLUMN_NAME
	,col.colid				as ORDINAL_POSITION
	,com.text				as DEFAULT_CLAUSE

from	sysobjects	c_obj
join 	syscomments	com on 	c_obj.id = com.id
join 	sysobjects	t_obj on c_obj.parent_obj = t_obj.id  
join    sysconstraints con on c_obj.id	= con.constid
join 	syscolumns	col on t_obj.id = col.id
			and con.colid = col.colid
where
    c_obj.xtype	= 'D'

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UninstallAccpacComponent]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UninstallAccpacComponent]
GO

CREATE PROCEDURE dbo.usp_UninstallAccpacComponent
  @ComponentName nvarchar(40) = NULL, 
  @ScreensOnly varchar(5) = 'FALSE'
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @SQL varchar(8000)

    IF @ComponentName is NULL
    BEGIN
      RAISERROR('usp_UninstallAccpacComponent: ComponentName parameter cannot be NULL',1,1)
      RETURN -1
    END

  DECLARE @EntityName nvarchar(40)

  DECLARE crs_Entities CURSOR FAST_FORWARD FOR 
        SELECT RTRIM(Bord_Name) FROM custom_tables
                   where bord_component = @ComponentName
  OPEN crs_Entities      
  FETCH NEXT FROM  crs_Entities INTO @EntityName
  WHILE @@FETCH_STATUS = 0
  BEGIN
    PRINT 'Removing ' + RTRIM(@EntityName) + '... '
    exec ('exec usp_UninstallAccpacEntity ' + @EntityName + ', ' + @ComponentName+ ', ' + @ScreensOnly)
    FETCH NEXT FROM  crs_Entities INTO @EntityName
  END

  CLOSE crs_Entities                    --Close cursor
  DEALLOCATE crs_Entities               --Deallocate cursor


RemoveComponent:
  PRINT 'Removing COMPONENT Entries...'
-- ****************************************************************************
-- * This block removes the component's Custom Properties that were added with 
-- *     CreateField calls in the .es script
-- *
IF (Upper(@ScreensOnly) != 'TRUE')
BEGIN

    PRINT '-- Cleaning up custom fields...'
    Delete From Custom_Edits WHERE ColP_Component = @ComponentName
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Edits records deleted.'

    Delete From Custom_Captions WHERE Capt_Component = @ComponentName

    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Captions records deleted.'

    -- ****************************************************************************
    -- * This block removes the entries that were added with 
    -- *     AddCustom_Views calls in the .es script
    -- *
        PRINT '-- Cleaning up renaming Custom_Views entries...'

        DECLARE @ViewTable TABLE(idx smallint identity, cuvi_viewname varchar(4000))    
        DECLARE @ViewCnt smallint, @ViewIdx smallint
        DECLARE @cuvi_viewname varchar(4000)
        INSERT INTO @ViewTable 
            select cuvi_viewname 
                from Custom_Views 
                where cuvi_Component = @ComponentName

        SELECT @ViewCnt = COUNT(1) FROM @ViewTable
        IF (@ViewCnt >= 1)
        BEGIN
            -- cycle through each field to drop
            SET @ViewIdx = 1
            WHILE (@ViewIdx >= 1)
            BEGIN
                SET @cuvi_viewname = null
                SELECT @cuvi_viewname = cuvi_viewname FROM @ViewTable WHERE idx = @ViewIdx
                IF (@cuvi_viewname  is not null)
                Begin
                    -- remove the old view
                    if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[' + @cuvi_viewname +']') 
                            and OBJECTPROPERTY(id, N'IsView') = 1)
                    BEGIN
                        SET @SQL = 'drop view [dbo].['+@cuvi_viewname + ']'
                        EXEC (@SQL)
                    END
                    DELETE FROM Custom_Views 
                        WHERE CuVi_Component = @ComponentName AND
                                CuVi_ViewName = @cuvi_viewname
                    
                    SET @ViewIdx = @ViewIdx + 1
                End
                ELSE
                Begin
                    SET @ViewIdx = -1
                End  
            END
        END
        PRINT convert(varchar, @ViewCnt) + ' Custom_Views records & Views deleted.'
    -- *
    -- * End AddCustom_Views() call block
    -- ****************************************************************************

END
-- *
-- * End CreateField() call block
-- ****************************************************************************

-- ****************************************************************************
-- * This block removes the entries that were added with 
-- *     AddCustom_Screens calls in the .es script
-- *
    PRINT '-- Cleaning up Screen entries...'
    Delete From Custom_Screens 
	where SeaP_SearchBoxName in 
	(select CObj_Name from Custom_ScreenObjects 
	 where CObj_Component = @ComponentName)
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Screens records deleted.'
-- *
-- * End AddCustom_Screens() call block
-- ****************************************************************************

-- ****************************************************************************
-- * This block removes the entries that were added with 
-- *     AddCustom_Lists calls in the .es script
-- *
    PRINT '-- Cleaning up Custom_Lists entries...'
    Delete From Custom_Lists 
	WHERE GriP_GridName in 
		(select CObj_Name from Custom_ScreenObjects 
			where CObj_Component = @ComponentName  )
	AND GriP_Component = @ComponentName
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Lists records deleted.'
-- *
-- * End AddCustom_Lists() call block
-- ****************************************************************************

-- ****************************************************************************
-- * This block removes the entries that were added with 
-- *     AddCustom_ScreenObjects calls in the .es script
-- *
    PRINT '-- Cleaning up Custom_ScreenObjects...'
    Delete From Custom_ScreenObjects WHERE CObj_Component = @ComponentName
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_ScreenObjects records deleted.'
-- *
-- * End AddCustom_ScreenObjects() call block
-- ****************************************************************************

-- ****************************************************************************
-- * This block removes the entries that were added with 
-- *     AddCustom_Tabs calls in the .es script
-- *
    PRINT '-- Cleaning up Custom_Tabs entries...'
    Delete From Custom_Tabs WHERE Tabs_Component = @ComponentName
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Tabs records deleted.'
-- *
-- * End AddCustom_Tabs() call block
-- ****************************************************************************


-- ****************************************************************************
-- * This block uninstalls the component's registration
-- *
    PRINT '-- Removing the component entry...'
    Delete From Components WHERE Cmp_Name = @ComponentName
    PRINT convert(varchar, @@ROWCOUNT) + ' Components records deleted.'
-- *
-- * End unistall component call block
-- ****************************************************************************

-- ****************************************************************************
-- * Update any SQL_Identity values and REP_Ranges that have been significantly
-- * modified.
-- *
    Declare @MaxId int
    Select @MaxId = Max(capt_captionid) from custom_captions
    Update SQL_Identity SET id_nextid = @MaxId + 1 where id_tableid = 39
    Update Rep_Ranges SET  
        range_rangestart        = @MaxId + 1,
        range_rangeend          = @MaxId + 50000,
        range_nextrangestart    = @MaxId + 50001,
        range_nextrangeend      = @MaxId + 100000,
        range_control_nextrange = @MaxId + 100001
    WHERE Range_TableID = 39
-- *
-- * End Update
-- ****************************************************************************
    SET NOCOUNT OFF
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_UninstallAccpacEntity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_UninstallAccpacEntity]
GO

CREATE PROCEDURE dbo.usp_UninstallAccpacEntity
  @EntityName varchar(40) = NULL, 
  @ComponentName nvarchar(40) = NULL,
  @ScreensOnly varchar(5) = 'FALSE'
AS
BEGIN
    IF @EntityName is NULL
    BEGIN
      RAISERROR('usp_UninstallAccpacEntity: EntityName parameter cannot be NULL',1,1)
      RETURN -1
    END
    IF @ComponentName is NULL
	SET @ComponentName = @EntityName

    DECLARE @TableId int
    DECLARE @Prefix varchar(10)
    DECLARE @SQL varchar(8000)

    SET NOCOUNT OFF

IF (Upper(@ScreensOnly) != 'TRUE')
BEGIN
-- ****************************************************************************
-- * This block removes the entities created by the CreateTable() call
-- *
    IF Exists(Select 1 from custom_tables 
		where Bord_Caption = @EntityName and Bord_Component is NULL)
    BEGIN
        PRINT @EntityName + ' is not a custom table. It is a out of the box accpac table.  We''ll proceed carefully.'
        -- get a list of the fields created previously by this component
        DECLARE @FieldTable TABLE(idx smallint identity, colp_colname varchar(4000))    
        DECLARE @FieldCnt smallint, @LoopIdx smallint
        DECLARE @colp_colname varchar(4000)
        PRINT 'Getting Columns for ' + @ComponentName + ' ' + @EntityName
        INSERT INTO @FieldTable 
            select colp_colname 
                from Custom_Edits 
                where colp_Entity = @EntityName AND colp_Component = @ComponentName

        SELECT @FieldCnt = COUNT(1) FROM @FieldTable
        PRINT 'Removing ' + convert(varchar, @FieldCnt) + ' Columns From ' + @EntityName
        IF (@FieldCnt >= 1)
        BEGIN
            --  We need to disable triggers or trx will stop the updates
    	    PRINT 'Disabling Triggers'
    	    SET @SQL = 'ALTER TABLE ' + @EntityName + ' DISABLE TRIGGER ALL' 
            EXEC (@SQL)
            -- cycle through each field to drop
            SET @LoopIdx = 1
            WHILE (@LoopIdx >= 1)
            BEGIN
                SET @colp_colname = null
                SELECT @colp_colname = colp_colname FROM @FieldTable WHERE idx = @Loopidx
                IF (@colp_colname  is not null)
                Begin
    	            --PRINT 'Setting ' + @EntityName + '.' + @colp_colname + ' = NULL'
    	            --SET @SQL = 'UPDATE ' + @EntityName + ' SET ' + @colp_colname + ' = NULL'
    	            --EXEC (@SQL)
    	            Declare @constname varchar(1000)
    	            set @CONSTNAME = NULL
    	            Select @constname = constraint_name from vDefaultConstraint where Column_Name = @colp_colname
    	            if (@constname is not null)
    	            begin
    	                
    	                PRINT 'Removing Default Constraint for ' + @EntityName + '.' + @colp_colname 
    	                SET @SQL = 'ALTER TABLE ' + @EntityName + ' DROP CONSTRAINT ' + @constname 
                        EXEC (@SQL)
    	            end
    	            PRINT 'Dropping Column ' + @EntityName + '.' + @colp_colname
    	            SET @SQL = 'ALTER TABLE ' + @EntityName + ' DROP COLUMN ' + @colp_colname 
                    EXEC (@SQL)
                    SET @LoopIdx = @LoopIdx + 1
                End
                ELSE
                Begin
                    SET @LoopIdx = -1
                End  
            END
            --  Re-enable any trigger
    	    SET @SQL = 'ALTER TABLE ' + @EntityName + ' ENABLE TRIGGER ALL' 
            EXEC (@SQL)
                
        END
    END  
    ELSE
    BEGIN
      PRINT '-- Dropping table...'
      IF Exists(Select 1 FROM sysobjects where name = @Entityname)
      BEGIN
        EXEC ('DROP TABLE ' + @EntityName)
        PRINT 'Dropped Table ''' + @EntityName + ''''
      END
      ELSE 
        PRINT 'No table with name '''+ @EntityName + ''' could be found.'
    END


    SELECT @TableId = Bord_TableID, @Prefix = RTrim(Bord_Prefix) from custom_tables 
	where Bord_Caption = @EntityName
    IF (@@ROWCOUNT = 0)
    BEGIN
      RAISERROR('usp_UninstallAccpacEntity: Unable to retrieve custom_table infomation.',1,1)
    END
    PRINT 'Prefix = '+@Prefix

    If Not Exists(SELECT 1 from custom_tables 
	where Bord_Caption = @EntityName and Bord_Component = @ComponentName)
    BEGIN
      PRINT 'Cannot remove custom_tables, rep_ranges, or SQL_Identity values.'
    END
    ELSE
    BEGIN    
      PRINT '-- Cleaning CreateTable & AddCustom_Table() entries...'
      DELETE From custom_tables WHERE Bord_TableID = @TableId
      PRINT convert(varchar, @@ROWCOUNT) + ' custom_tables records deleted.'
      DELETE From Rep_Ranges WHERE Range_TableID = @TableId
      PRINT convert(varchar, @@ROWCOUNT) + ' Rep_Ranges records deleted.'
      DELETE From SQL_Identity WHERE ID_TableID = @TableId
      PRINT convert(varchar, @@ROWCOUNT) + ' SQL_Identity records deleted.'
    END
-- *
-- * End CreateTable() call block
-- ****************************************************************************
-- ****************************************************************************
-- * This block removes the entity's Custom Properties that were added with 
-- *     CreateField calls in the .es script
-- *
    PRINT '-- Cleaning up custom fields...'
    Delete From Custom_Edits WHERE ColP_Component = @ComponentName AND ColP_Entity = @EntityName
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Edits records deleted.'

    SET @SQL = 'Delete From Custom_Captions WHERE Capt_Component = ''' + @ComponentName+
          ''' and (Capt_code like '''+ @Prefix+'_%'' or Capt_code = ''' +@EntityName+
          ''' or Capt_Family = '''+@EntityName+''')'
    EXEC (@SQL)

    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Captions records deleted.'
-- *
-- * End CreateField() call block
-- ****************************************************************************

-- ****************************************************************************
-- * This block removes the entries that were added with 
-- *     AddCustom_Views calls in the .es script
-- *
    PRINT '-- Cleaning up Custom_Views entries...'

    DECLARE @ViewTable TABLE(idx smallint identity, cuvi_viewname varchar(4000))    
    DECLARE @ViewCnt smallint, @ViewIdx smallint
    DECLARE @cuvi_viewname varchar(4000)
    INSERT INTO @ViewTable 
        select cuvi_viewname 
            from Custom_Views 
            where cuvi_Entity = @EntityName AND cuvi_Component = @ComponentName

    SELECT @ViewCnt = COUNT(1) FROM @ViewTable
    IF (@ViewCnt >= 1)
    BEGIN
        -- cycle through each field to drop
        SET @ViewIdx = 1
        WHILE (@ViewIdx >= 1)
        BEGIN
            SET @cuvi_viewname = null
            SELECT @cuvi_viewname = cuvi_viewname FROM @ViewTable WHERE idx = @ViewIdx
            IF (@cuvi_viewname  is not null)
            Begin
                -- remove the old view
                if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[' + @cuvi_viewname +']') 
                        and OBJECTPROPERTY(id, N'IsView') = 1)
                BEGIN
                    SET @SQL = 'drop view [dbo].['+@cuvi_viewname + ']'
                    EXEC (@SQL)
                END
                DELETE FROM Custom_Views 
                    WHERE CuVi_Component = @ComponentName AND
                            CuVi_Entity = @EntityName AND
                            CuVi_ViewName = @cuvi_viewname
                
                SET @ViewIdx = @ViewIdx + 1
            End
            ELSE
            Begin
                SET @ViewIdx = -1
            End  
        END
    END
    PRINT convert(varchar, @ViewCnt) + ' Custom_Views records & Views deleted.'


-- *
-- * End AddCustom_Views() call block
-- ****************************************************************************

END
-- ****************************************************************************
-- * This block removes the entity's Custom Properties that were added with 
-- *     CreateField calls in the .es script
-- *
    PRINT '-- Cleaning up custom caption fields...'

    SET @SQL = 'Delete From Custom_Captions WHERE Capt_Component = ''' + @ComponentName+
          ''' and (Capt_code = ''' +@EntityName+
          ''' or Capt_Family = '''+@EntityName+''')'
    EXEC (@SQL)

    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Captions records deleted.'
-- *
-- * End CreateField() call block
-- ****************************************************************************

-- ****************************************************************************
-- * This block removes the entries that were added with 
-- *     AddCustom_Screens calls in the .es script
-- *
    PRINT '-- Cleaning up Screen entries...'
    Delete From Custom_Screens 
	where SeaP_SearchBoxName in 
	(select CObj_Name from Custom_ScreenObjects 
	 where CObj_EntityName = @EntityName
		AND CObj_Component = @ComponentName)
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Screens records deleted.'
-- *
-- * End AddCustom_Screens() call block
-- ****************************************************************************

-- ****************************************************************************
-- * This block removes the entries that were added with 
-- *     AddCustom_Lists calls in the .es script
-- *
    PRINT '-- Cleaning up Custom_Lists entries...'
    Delete From Custom_Lists 
	WHERE GriP_GridName in 
		(select CObj_Name from Custom_ScreenObjects 
			where CObj_EntityName = @EntityName
			AND CObj_Component = @ComponentName  )
	AND GriP_Component = @ComponentName
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Lists records deleted.'
-- *
-- * End AddCustom_Lists() call block
-- ****************************************************************************

-- ****************************************************************************
-- * This block removes the entries that were added with 
-- *     AddCustom_ScreenObjects calls in the .es script
-- *
    PRINT '-- Cleaning up Custom_ScreenObjects...'
    Delete From Custom_ScreenObjects WHERE CObj_EntityName = @EntityName AND CObj_Component = @ComponentName
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_ScreenObjects records deleted.'
-- *
-- * End AddCustom_ScreenObjects() call block
-- ****************************************************************************

-- ****************************************************************************
-- * This block removes the entries that were added with 
-- *     AddCustom_Tabs calls in the .es script
-- *
    -- TODO: Also delete the Physical Views
    PRINT '-- Cleaning up Custom_Tabs entries...'
    Delete From Custom_Tabs WHERE Tabs_Entity = @EntityName 
				AND Tabs_Component = @ComponentName
    PRINT convert(varchar, @@ROWCOUNT) + ' Custom_Tabs records deleted.'
-- *
-- * End AddCustom_Tabs() call block
-- ****************************************************************************
    SET NOCOUNT OFF
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

