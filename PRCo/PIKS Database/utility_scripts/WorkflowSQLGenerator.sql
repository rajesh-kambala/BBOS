
If Exists (Select name from sysobjects where name = 'usp_Workflow_ScriptAllCustom' and type='P') 
	Drop Procedure   usp_Workflow_ScriptAllCustom
Go
CREATE PROCEDURE [dbo].[usp_Workflow_ScriptAllCustom]
	@PhysicallyDeleteAllExisting bit = 0,
	@LogicallyDeleteAllExisting bit = 1
AS 
BEGIN
	-- Headers
	PRINT '-- ***********************************************************'
	PRINT '-- * This file was scripted by the WorkflowSQLGenerator.sql file'
	PRINT '-- * This file should not be changed manually. Changes should '
	PRINT '-- * be made to the generator file. '
	PRINT '-- *'
	PRINT '-- *'
	PRINT '-- ***********************************************************'

	-- set up the declaration required by all workflow scripting 
	PRINT 'DECLARE @IDTable_State TABLE(ndx int identity, IdValue int, NewIdValue int)'
	PRINT 'DECLARE @IDTable_Rules TABLE(ndx int identity, IdValue int, NewIdValue int)'

	PRINT 'Declare @WorkflowRuleId int'
	PRINT 'Declare @WorkflowStateId int'
	PRINT 'Declare @WorkflowId int'
	PRINT 'Declare @WorkflowTransitionId int'
	PRINT 'Declare @NewStateId int'
	PRINT 'Declare @NewNextStateId int'
	PRINT 'Declare @NewRuleId int'

	PRINT ''
	PRINT 'Declare @SystemUserId int'
	PRINT 'SELECT @SystemUserId = dbo.ufn_GetSystemUserId(3)'

	if (@PhysicallyDeleteAllExisting = 1)
	Begin	
		PRINT ''
		PRINT '-- DELETE ALL Existing Workflows created by our system user'
		PRINT 'DELETE FROM Workflow where work_createdby = @SystemUserId '
		PRINT 'DELETE FROM WorkflowRules where wkrl_createdby = @SystemUserId '
		PRINT 'DELETE FROM WorkflowState where wkst_createdby = @SystemUserId '
		PRINT 'DELETE FROM WorkflowTransition where wktr_createdby = @SystemUserId '
	End else if (@LogicallyDeleteAllExisting = 1) Begin
		PRINT ''
		PRINT '-- "Logically Delete" ALL Existing Workflows created by our system user'
		PRINT 'update Workflow set work_Deleted = 1, work_enabled = ''N'' where work_createdBy = @SystemUserId '
	End
	
	-- Disable some of the native workflows
	PRINT ''	
	PRINT '-- Disable the native Opportunity and Case workflows'
	PRINT 'UPDATE Workflow SET work_Enabled = ''N'' where work_workflowid in (1,2) '
	PRINT ''	

	--exec usp_WorkflowScripter 'TestOpp', 0  
	exec usp_WorkflowScripter 'Blueprints Advertisement Opportunity Workflow', 0  
	exec usp_WorkflowScripter 'New Membership Opportunity', 0  
	exec usp_WorkflowScripter 'Upgrade Membership Opportunity', 0  
	exec usp_WorkflowScripter 'Special Services Workflow', 0 
	exec usp_WorkflowScripter 'Customer Care Workflow', 0 

END
GO

If Exists (Select name from sysobjects where name = 'usp_WorkflowScripter' and type='P') 
	Drop Procedure   usp_WorkflowScripter
Go

CREATE PROCEDURE [dbo].[usp_WorkflowScripter]
	@SourceWorkflowName varchar(500),
	@IncludeDeclares bit = 1
AS 
BEGIN
	SET NOCOUNT ON
	if (@IncludeDeclares = 1)
	begin
		PRINT 'DECLARE @IDTable_State TABLE(ndx int identity, IdValue int, NewIdValue int)'
		PRINT 'DECLARE @IDTable_Rules TABLE(ndx int identity, IdValue int, NewIdValue int)'

		PRINT 'Declare @WorkflowRuleId int'
		PRINT 'Declare @WorkflowStateId int'
		PRINT 'Declare @WorkflowId int'
		PRINT 'Declare @WorkflowTransitionId int'
		PRINT 'Declare @NewStateId int'
		PRINT 'Declare @NewNextStateId int'
		PRINT 'Declare @NewRuleId int'

		PRINT 'Declare @SystemUserId int'
		PRINT 'SELECT @SystemUserId = dbo.ufn_GetSystemUserId(3)'
	end
	PRINT ''


	PRINT '-- **************  SCRIPTING ' + @SourceWorkflowName + ' ************************'
	
	Declare @Line varchar (2000)
	Declare @NOW varchar(100)
	Declare @SourceWorkflowId int
	SELECT   @SourceWorkflowId = Work_WorkflowId FROM Workflow 
		WHERE work_Description = @SourceWorkflowName and Work_Deleted is null

	DECLARE @IDTable_State TABLE(ndx int identity, IdValue int)
	DECLARE @IDTable_Rules TABLE(ndx int identity, IdValue int)
	DECLARE @IDTable_Transition TABLE(ndx int identity, IdValue int)

	SET @NOW = '''' + Convert(varchar, getdate(), 109) + ''''

	PRINT '-- Create the Workflow Record'
	PRINT 'exec usp_getNextId ''Workflow'', @WorkflowId output '
	SELECT @Line = 'INSERT INTO Workflow VALUES (' + 
			'@WorkflowId, ''' + RTRIM(work_description) + ''', @SystemUserId, ' 
			+ @NOW + ', @SystemUserId, ' 
			+ @NOW + ', ' + @NOW + ', ' 
			+ 'NULL, NULL)'
	FROM Workflow 
	WHERE work_WorkflowId = @SourceWorkflowId 

	PRINT @Line
	PRINT ''

	DECLARE @LookupId int, @ndx int
	DELETE FROM @IDTable_State
	INSERT INTO @IDTable_State
		Select wkst_StateId from WorkflowState where wkst_WorkflowId = @SourceWorkflowId 

	SELECT @ndx = MIN(ndx) from @IDTable_State
	SELECT @LookupId = IdValue from @IDTable_State where ndx = @ndx
	PRINT '-- Create the Workflow State Records'
	WHILE (@LookupId is not null)
	BEGIN
		SELECT @Line = 'INSERT INTO WorkflowState VALUES (' + 
				'@WorkflowStateId, @WorkflowId, ' +
				Coalesce('''' + RTRIM(wkst_Name) + '''', 'NULL') + ', ' + 
				Coalesce('''' + Convert(varchar(2000),wkst_Description)+ '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkst_IsEntryPoint) + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkst_Time) + '''', 'NULL') + ', @SystemUserId, ' + 
				@NOW + ', @SystemUserId, ' +
				@NOW + ', ' + @NOW + ', ' + 
				'NULL)'
		FROM WorkflowState 
		WHERE wkst_StateId = @LookupId 
		-- Output
		PRINT 'exec usp_getNextId ''WorkflowState'', @WorkflowStateId output '
		PRINT @Line
		PRINT 'INSERT INTO @IDTable_State VALUES (' + convert(varchar, @LookupId) + ', @WorkflowStateId)'
		SET @ndx = @ndx+1
		SET @LookupId = NULL
		SELECT @LookupId = IdValue from @IDTable_State where ndx = @ndx
	END

	-- Create the WorkflowRules
	DELETE FROM @IDTable_Rules
	INSERT INTO @IDTable_Rules
		Select wkrl_RuleId from WorkflowRules 
			where wkrl_WorkflowId = @SourceWorkflowId 

	SELECT @ndx = MIN(ndx) from @IDTable_Rules
	SET @LookupId = NULL
	SELECT @LookupId = IdValue from @IDTable_Rules where ndx = @ndx

	PRINT '-- Create the WorkflowRules Records'
	WHILE (@LookupId is not null)
	BEGIN
			
		SELECT @Line = 'INSERT INTO WorkflowRules VALUES (' + 
				'@WorkflowRuleId, ' +
				Coalesce('''' + RTRIM(wkrl_RuleType) + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_Caption) + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_Image) + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_Table) + '''', 'NULL') + ', ' + 
				Coalesce('''' + CONVERT(varchar(2000), wkrl_WhereClause) + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_ActionGroupId) + '''', 'NULL') + ', ' + 
				Coalesce(convert(varchar(20), wkrl_Channel), 'NULL') + ', @SystemUserId, ' + 
				@NOW + ', @SystemUserId, ' + @NOW + ', ' + @NOW + ', '  +
				Coalesce('''' + convert(varchar(10),wkrl_Deleted) + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_Entity) + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_CustomFile) + '''', 'NULL') + ', ' + 
				Coalesce(convert(varchar(20), wkrl_Order), 'NULL') + ', ' + 
				Coalesce('''' + Replace(convert(varchar(3000), wkrl_Javascript), '''', '''''') + '''', 'NULL') + ', ' + 
				'@WorkflowId, ' +
				Coalesce('''' + RTRIM(wkrl_Cloneable) + '''', 'NULL') + ', ' + 
				Coalesce(convert(varchar(20), wkrl_RunInterval), 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_NextRunTime) + '''', 'NULL') + ', ' + 
				Coalesce('''' + wkrl_Enabled + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_Type) + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_AndOr) + '''', 'NULL') + ', ' + 
				Coalesce('''' + RTRIM(wkrl_UserId) + '''', 'NULL') + 
				')'
		FROM WorkflowRules 
		WHERE wkrl_RuleId = @LookupId 
		-- Output
		PRINT 'exec usp_getNextId ''WorkflowRules'', @WorkflowRuleId output '
		PRINT @Line
		PRINT 'INSERT INTO @IDTable_Rules VALUES (' + convert(varchar, @LookupId) + ', @WorkflowRuleId)'

		SET @ndx = @ndx+1
		SET @LookupId = NULL
		SELECT @LookupId = IdValue from @IDTable_Rules where ndx = @ndx
	END

	-- Creation of the WorkflowTransition
	DELETE FROM @IDTable_Transition
	INSERT INTO @IDTable_Transition
		Select wktr_TransitionId from WorkflowTransition where wktr_WorkflowId = @SourceWorkflowId 

	SELECT @ndx = MIN(ndx) from @IDTable_Transition
	SELECT @LookupId = IdValue from @IDTable_Transition where ndx = @ndx
	PRINT '-- Create the Workflow Transition Records'
	WHILE (@LookupId is not null)
	BEGIN
		SELECT @Line = 'SELECT @NewStateId = NewIdValue FROM @IDTable_State ' + 
					'WHERE IdValue = ' + convert(varchar, wktr_StateId)
			FROM WorkflowTransition WHERE wktr_TransitionId = @LookupId
		PRINT @Line
		
		DECLARE @wktr_NextStateId int 
		SELECT @wktr_NextStateId = wktr_NextStateId FROM WorkflowTransition WHERE wktr_TransitionId = @LookupId
		IF (@wktr_NextStateId is NULL)
			SET @Line = 'SET @NewNextStateId = NULL ' 
		ELSE  
			SET @Line = 'SELECT @NewNextStateId = NewIdValue FROM @IDTable_State ' + 
					'WHERE IdValue = ' + convert(varchar, @wktr_NextStateId)
		
		PRINT @Line

		DECLARE @wktr_NewRuleId int 
		SELECT @wktr_NewRuleId = wktr_RuleId FROM WorkflowTransition WHERE wktr_TransitionId = @LookupId
		IF (@wktr_NewRuleId is NULL)
			SET @Line = 'SET @NewRuleId = NULL ' 
		ELSE  
			SELECT @Line = 'SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules ' + 
					'WHERE IdValue = ' + convert(varchar, @wktr_NewRuleId)
		
		PRINT @Line

		SELECT @Line = 'INSERT INTO WorkflowTransition VALUES (' + 
				'@WorkflowTransitionId, @WorkflowId, ' +
				'@NewStateId, @NewNextStateId, @NewRuleId, ' +
				'@SystemUserId, ' + @NOW + ', '  +
				'@SystemUserId, ' + @NOW + ', ' + @NOW + ', ' +
				Coalesce('''' + convert(varchar(10),wktr_Deleted) + '''', 'NULL') + ', ' + 
				Coalesce('''' + wktr_Condition + '''', 'NULL') + ', ' + 
				Coalesce('''' + wktr_Expanded + '''', 'NULL') + 
				')'
		FROM WorkflowTransition 
		WHERE wktr_TransitionId = @LookupId 
		-- Output
		PRINT 'exec usp_getNextId ''WorkflowTransition'', @WorkflowTransitionId output '
		PRINT @Line

		SET @ndx = @ndx+1
		SET @LookupId = NULL
		SELECT @LookupId = IdValue from @IDTable_Transition where ndx = @ndx
	END
	PRINT ''
	PRINT '-- Activate the workflow'
	PRINT 'UPDATE Workflow SET work_Enabled = ''Y'' WHERE work_WorkflowId = @WorkflowId'
	PRINT ''

	PRINT '-- **************  SCRIPTING ' + @SourceWorkflowName + ' COMPLETE ***************'
	PRINT ''
	PRINT ''
	SET NOCOUNT OFF
END
GO

exec usp_Workflow_ScriptAllCustom 0,1
