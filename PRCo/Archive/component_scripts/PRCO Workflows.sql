-- ***********************************************************
-- * This file was scripted by the WorkflowSQLGenerator.sql file
-- * This file should not be changed manually. Changes should 
-- * be made to the generator file. 
-- *
-- *
-- ***********************************************************
DECLARE @IDTable_State TABLE(ndx int identity, IdValue int, NewIdValue int)
DECLARE @IDTable_Rules TABLE(ndx int identity, IdValue int, NewIdValue int)
Declare @WorkflowRuleId int
Declare @WorkflowStateId int
Declare @WorkflowId int
Declare @WorkflowTransitionId int
Declare @NewStateId int
Declare @NewNextStateId int
Declare @NewRuleId int
 
Declare @SystemUserId int
SELECT @SystemUserId = dbo.ufn_GetSystemUserId(3)
 
-- "Logically Delete" ALL Existing Workflows created by our system user
update Workflow set work_Deleted = 1, work_enabled = 'N' where work_createdBy = @SystemUserId 
 
-- Disable the native Opportunity and Case workflows
UPDATE Workflow SET work_Enabled = 'N' where work_workflowid in (1,2) 
 
 
-- **************  SCRIPTING Blueprints Advertisement Opportunity Workflow ************************
-- Create the Workflow Record
exec usp_getNextId 'Workflow', @WorkflowId output 
INSERT INTO Workflow VALUES (@WorkflowId, 'Blueprints Advertisement Opportunity Workflow', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL)
 
-- Create the Workflow State Records
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Start', NULL, 'Y', NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL)
INSERT INTO @IDTable_State VALUES (37, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Initial', 'This is the initial state of a BP ad opportunity', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL)
INSERT INTO @IDTable_State VALUES (38, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Qualified', 'In this state, a sales rep has contacted the company and qualified the opportunity further.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL)
INSERT INTO @IDTable_State VALUES (39, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Proposal Submitted', 'In this state, a sales rep (or administrative person) will have sent the company BP advertising information and agreement.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL)
INSERT INTO @IDTable_State VALUES (40, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Negotiating', 'In this state, the company has expressed strong interest in BP advertising and is communicating with a sales rep about price/package options and other final details.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL)
INSERT INTO @IDTable_State VALUES (41, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Sale Closed', 'In this state, the company has returned all necessary material and the BP ad is considered sold.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL)
INSERT INTO @IDTable_State VALUES (42, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Deal Lost', 'In this state, the company has decided not to advertise in BP and the BP ad opportunity is considered lost.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL)
INSERT INTO @IDTable_State VALUES (43, @WorkflowStateId)
-- Create the WorkflowRules Records
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'New', 'New Blueprints Opportunity', 'NewOpportunity.gif', 'Opportunity', NULL, '10128', NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, 'Opportunity', 'PROpportunity/PRBlueprintsOpportunity.asp', 1, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10127, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Submit Proposal', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, 'Opportunity', 'PROpportunity/PRBlueprintsOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10128, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Qualify', 'WorkflowDefault.gif', 'Opportunity', NULL, '10126', NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, 'Opportunity', 'PROpportunity/PRBlueprintsOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10129, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Negotitate', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, 'Opportunity', 'PROpportunity/PRBlueprintsOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10130, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Sold', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, 'Opportunity', 'PROpportunity/PRBlueprintsOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10131, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Lost for Target Issue', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, 'Opportunity', 'PROpportunity/PRBlueprintsOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10132, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Not Sold', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, 'Opportunity', 'PROpportunity/PRBlueprintsOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10133, @WorkflowRuleId)
-- Create the Workflow Transition Records
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 37
SET @NewNextStateId = NULL 
SET @NewRuleId = NULL 
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 37
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 38
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10127
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 38
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 39
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10129
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 39
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 40
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10128
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 39
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 39
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10132
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 39
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 43
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10133
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 40
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 41
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10130
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 40
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 40
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10132
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 40
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 43
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10133
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 41
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 42
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10131
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 41
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 41
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10132
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 41
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 43
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10133
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 40
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 42
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10131
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:557AM', @SystemUserId, 'Nov 16 2006 12:50:43:557AM', 'Nov 16 2006 12:50:43:557AM', NULL, NULL, 'y')
 
-- Activate the workflow
UPDATE Workflow SET work_Enabled = 'Y' WHERE work_WorkflowId = @WorkflowId
 
-- **************  SCRIPTING Blueprints Advertisement Opportunity Workflow COMPLETE ***************
 
 
 
-- **************  SCRIPTING New Membership Opportunity ************************
-- Create the Workflow Record
exec usp_getNextId 'Workflow', @WorkflowId output 
INSERT INTO Workflow VALUES (@WorkflowId, 'New Membership Opportunity', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL)
 
-- Create the Workflow State Records
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Start', NULL, 'Y', NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL)
INSERT INTO @IDTable_State VALUES (44, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Initial', 'This is the initial state of a New Membership opportunity.  This may originate from a sales representative.  Alternatively, an administrative person may establish the opportunity (i.e. based upon an internal retrieval) and then assign the opportunity to a sales rep to qualify the opportunity.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL)
INSERT INTO @IDTable_State VALUES (45, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Qualified', 'In this state, a sales rep has contacted the company and qualified the opportunity further.  An updated forecast amount and certainty, and a close by target date, will be required fields.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL)
INSERT INTO @IDTable_State VALUES (46, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Proposal Submitted', 'In this state, a sales rep (or administrative person) will have sent the company Membership information and agreement.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL)
INSERT INTO @IDTable_State VALUES (47, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Negotiating', 'In this state, the company has expressed strong interest in Membership and is communicating with a sales rep about price/package options and other final details.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL)
INSERT INTO @IDTable_State VALUES (48, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Sale Closed', 'In this state, the company has returned all necessary material and the Membership is considered sold.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL)
INSERT INTO @IDTable_State VALUES (49, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Deal Lost', 'In this state, the company has decided not to become a Member and the opportunity is considered lost.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL)
INSERT INTO @IDTable_State VALUES (50, @WorkflowStateId)
-- Create the WorkflowRules Records
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Submit Proposal', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, 'Company', 'PROpportunity/PRMembershipOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10134, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Not Sold', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, 'Company', 'PROpportunity/PRMembershipOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10135, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Qualify', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, 'Company', 'PROpportunity/PRMembershipOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10136, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Sold', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, 'Company', 'PROpportunity/PRMembershipOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10137, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Negotiate', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, 'Company', 'PROpportunity/PRMembershipOpportunity.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10138, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'New', 'New Membership Opportunity', 'NewOpportunity.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, 'Company', 'PROpportunity/PRMembershipOpportunity.asp', 2, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10139, @WorkflowRuleId)
-- Create the Workflow Transition Records
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 44
SET @NewNextStateId = NULL 
SET @NewRuleId = NULL 
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 44
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 45
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10139
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 45
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 46
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10136
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 46
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 47
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10134
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 46
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 50
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10135
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 47
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 49
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10137
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 47
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 48
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10138
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 47
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 50
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10135
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 48
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 49
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10137
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 48
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 50
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10135
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:837AM', @SystemUserId, 'Nov 16 2006 12:50:43:837AM', 'Nov 16 2006 12:50:43:837AM', NULL, NULL, 'y')
 
-- Activate the workflow
UPDATE Workflow SET work_Enabled = 'Y' WHERE work_WorkflowId = @WorkflowId
 
-- **************  SCRIPTING New Membership Opportunity COMPLETE ***************
 
 
 
-- **************  SCRIPTING Upgrade Membership Opportunity ************************
-- Create the Workflow Record
exec usp_getNextId 'Workflow', @WorkflowId output 
INSERT INTO Workflow VALUES (@WorkflowId, 'Upgrade Membership Opportunity', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL)
 
-- Create the Workflow State Records
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Start', NULL, 'Y', NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL)
INSERT INTO @IDTable_State VALUES (51, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Initial', 'This is the initial state of a Membership upgrade opportunity.  This may originate from a sales representative.  Alternatively, an administrative person may establish the opportunity (i.e. based upon an internal retrieval) and then assign the opportunity to a sales rep to qualify the opportunity.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL)
INSERT INTO @IDTable_State VALUES (52, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Qualified', 'In this state, a sales rep has contacted the company and qualified the opportunity further.  An updated forecast amount and certainty, and a close by target date, will be required fields.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL)
INSERT INTO @IDTable_State VALUES (53, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Proposal Submitted', 'In this state, a sales rep (or administrative person) will have sent the company service information and agreement.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL)
INSERT INTO @IDTable_State VALUES (54, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Negotiating', 'In this state, the company has expressed strong interest in a Membership upgrade and is communicating with a sales rep about price/package options and other final details.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL)
INSERT INTO @IDTable_State VALUES (55, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Sale Closed', 'In this state, the company has returned all necessary material and the Membership upgrade is considered sold.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL)
INSERT INTO @IDTable_State VALUES (56, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Deal Lost', 'In this state, the company has decided not to upgrade service, and the opportunity is considered lost.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL)
INSERT INTO @IDTable_State VALUES (57, @WorkflowStateId)
-- Create the WorkflowRules Records
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'New', 'New Membership Upgrade Opportunity', 'NewOpportunity.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, 'Company', 'PROpportunity/PRMembershipUpgradeOpp.asp', 3, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10140, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Submit Proposal', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, 'Company', 'PROpportunity/PRMembershipUpgradeOpp.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10141, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Not Sold', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, 'Company', 'PROpportunity/PRMembershipUpgradeOpp.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10142, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Qualify', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, 'Company', 'PROpportunity/PRMembershipUpgradeOpp.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10143, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Sold', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, 'Company', 'PROpportunity/PRMembershipUpgradeOpp.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10144, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Negotiate', 'WorkflowDefault.gif', 'Opportunity', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, 'Company', 'PROpportunity/PRMembershipUpgradeOpp.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10145, @WorkflowRuleId)
-- Create the Workflow Transition Records
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 51
SET @NewNextStateId = NULL 
SET @NewRuleId = NULL 
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 51
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 52
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10140
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 52
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 53
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10143
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 53
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 54
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10141
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 53
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 57
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10142
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 54
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 56
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10144
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 54
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 55
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10145
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 54
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 57
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10142
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 55
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 56
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10144
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 55
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 57
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10142
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:930AM', @SystemUserId, 'Nov 16 2006 12:50:43:930AM', 'Nov 16 2006 12:50:43:930AM', NULL, NULL, 'y')
 
-- Activate the workflow
UPDATE Workflow SET work_Enabled = 'Y' WHERE work_WorkflowId = @WorkflowId
 
-- **************  SCRIPTING Upgrade Membership Opportunity COMPLETE ***************
 
 
 
-- **************  SCRIPTING Special Services Workflow ************************
-- Create the Workflow Record
exec usp_getNextId 'Workflow', @WorkflowId output 
INSERT INTO Workflow VALUES (@WorkflowId, 'Special Services Workflow', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL)
 
-- Create the Workflow State Records
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Start', NULL, 'Y', NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (58, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Initial', 'This is the initial state when a potential collection is received (via phone, fax or e-mail).  If Creditor is not a Member, need to discuss with Sales how to handle data entry and follow up.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (59, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Wait PLAN Accept Ltr', 'Waiting for PLAN Acceptance Letter', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (60, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'PLAN Control', 'At this point, we want an internal "file number" for tracking purposes.  Need to determine when a file number is created and when it applies during each workflow stage.  During this stage, we will want to track communication between PRCo and the PLAN partner.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (61, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Collected by PLAN', 'This is the state when the PLAN partner confirms they collected.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (62, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Uncollected by PLAN', 'This is the state when the PLAN partner confirms they can not collect.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (63, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Litigation', 'This is the state when the PLAN partner confirms the parties have gone to court.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (64, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Collection File Open', 'This is the state when the Creditor has asked us for our "free letter."', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (65, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Waiting', 'State when the Creditor has asked us for our "Free Letter."', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (66, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Formal Claim', 'This is the state when PRCo is formally collecting for Creditor and will invoice Creditor for any amounts collected on their behalf.  In this state, Kathleen will perform a number of tasks, but they are not automated (these could include: faxing form letters, copies of some/all paperwork received from either party, internal/external communication; follow up calendar; reporting (56) or (57) in Credit Sheet) -- we will want to track these activities.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (67, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Collected/ Resolved', 'This is the state when Creditor confirms with PRCo that they received payment.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (68, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Payment Schedule', 'This is the state when Debtor agrees to a payment schedule.  In this state, Kathleen will routinely follow up with Creditor to confirm the Debtor is adhering to the payment schedule.  If the schedule is not adhered to, we may report (56) or (57) in Credit Sheet.  PRCo will invoice Creditor for amounts collected.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (69, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Qualified', 'This is state after we have collected information from the Gather Info Action.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (70, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Pending', 'This is the state after we Provide Advice.  Waiting for more information from claimant.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (71, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Assistance Requested', 'In this state, the Claimant has requested that PRCo handlethe dispute for them and PRCo is awaiting signed authorization.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (72, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Assist in Progress', 'In this state, PRCo is exchanging documentation and communication with the Respondent and the Claimant to bring resolution to the dispute.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (73, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Closed', 'In this state, PRCo believes that the file will no longer be worked on. However, it is possible that the file will be re-opened.', NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL)
INSERT INTO @IDTable_State VALUES (74, @WorkflowStateId)
-- Create the WorkflowRules Records
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Gather Info', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10146, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'New', 'New Special Services File', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10147, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Send PLAN Info', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', 2, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10148, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Go To PLAN', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10149, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'PLAN Collects', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10150, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'PLAN Closes', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10151, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Go To Court', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10152, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Open Claim', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', 1, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10153, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Close', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', 200, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10154, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Debtor Paperwork Received', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10155, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Go To Collection', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10156, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'PRCo Resolves', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', 150, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10157, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Re-Open', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', '1', 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10158, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Negotiate Payment Schedule', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10159, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Provide Advice', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, 'Valid=(prfi_type==''O''||(prfi_type==''M''&&prfi_status==''Open''));', @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10160, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Request Dispute Assistance', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', '1', 'PRFile', 'PRFile/PRFile.asp', 6, 'Valid=(prfi_type==''D''||( (prfi_type==''M''|| prfi_type==''C'') &&prfi_status==''Open''));', @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10161, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Commence Dispute Assistance', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', '1', 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10162, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Re-Open Claim', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', '1', 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10163, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Re-Open Claim', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, 'Valid=(prfi_type==''C'');', @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10164, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Closed to Wait PLAN Accept Ltr', NULL, 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10165, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Formal Claim to Collection File Open', NULL, 'Cases', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', '1', NULL, NULL, NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10170, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Formal Claim to Collection File Open', NULL, 'Cases', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', '1', NULL, NULL, NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10171, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Send A-1', 'WorkflowDefault.gif', 'PRFile', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, 'PRFile', 'PRFile/PRFile.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10172, @WorkflowRuleId)
-- Create the Workflow Transition Records
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 58
SET @NewNextStateId = NULL 
SET @NewRuleId = NULL 
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 58
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 59
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10147
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 59
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 70
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10146
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 70
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 60
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10148
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 70
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 67
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10153
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 60
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 74
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10154
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 60
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 61
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10149
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 61
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 62
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10150
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 61
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 63
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10151
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 61
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 64
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10152
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 64
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 62
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10150
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 64
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 63
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10151
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 74
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 67
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10164
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 67
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 69
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10159
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 59
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 74
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10154
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 67
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 60
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10148
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 67
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 74
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10154
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 59
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 71
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10160
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 71
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 70
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10146
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 71
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 71
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10160
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 71
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 74
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10154
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 67
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 68
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10157
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 68
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 67
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10164
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 68
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 74
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10154
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 70
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 66
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10172
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 70
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 74
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10154
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 66
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 67
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10153
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 66
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 74
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10154
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 69
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 68
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10157
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 69
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 60
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10148
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:43:980AM', @SystemUserId, 'Nov 16 2006 12:50:43:980AM', 'Nov 16 2006 12:50:43:980AM', NULL, NULL, 'y')
 
-- Activate the workflow
UPDATE Workflow SET work_Enabled = 'Y' WHERE work_WorkflowId = @WorkflowId
 
-- **************  SCRIPTING Special Services Workflow COMPLETE ***************
 
 
 
-- **************  SCRIPTING Customer Care Workflow ************************
-- Create the Workflow Record
exec usp_getNextId 'Workflow', @WorkflowId output 
INSERT INTO Workflow VALUES (@WorkflowId, 'Customer Care Workflow', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, NULL)
 
-- Create the Workflow State Records
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Start', NULL, 'Y', NULL, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL)
INSERT INTO @IDTable_State VALUES (75, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Logged', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL)
INSERT INTO @IDTable_State VALUES (76, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Researching', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL)
INSERT INTO @IDTable_State VALUES (77, @WorkflowStateId)
exec usp_getNextId 'WorkflowState', @WorkflowStateId output 
INSERT INTO WorkflowState VALUES (@WorkflowStateId, @WorkflowId, 'Closed', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL)
INSERT INTO @IDTable_State VALUES (78, @WorkflowStateId)
-- Create the WorkflowRules Records
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'New', 'New Case', 'WorkflowDefault.gif', 'Cases', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, 'Cases', 'PRCase/PRCustomerCare.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10166, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Close', 'WorkflowDefault.gif', 'Cases', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, 'Cases', 'PRCase/PRCustomerCare.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10167, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Pending', 'WorkflowDefault.gif', 'Cases', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, 'Cases', 'PRCase/PRCustomerCare.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10168, @WorkflowRuleId)
exec usp_getNextId 'WorkflowRules', @WorkflowRuleId output 
INSERT INTO WorkflowRules VALUES (@WorkflowRuleId, 'Pre', 'Re-open', 'WorkflowDefault.gif', 'Cases', NULL, NULL, NULL, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, 'Cases', 'PRCase/PRCustomerCare.asp', NULL, NULL, @WorkflowId, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT INTO @IDTable_Rules VALUES (10169, @WorkflowRuleId)
-- Create the Workflow Transition Records
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 75
SET @NewNextStateId = NULL 
SET @NewRuleId = NULL 
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 75
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 76
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10166
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 76
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 77
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10168
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 76
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 78
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10167
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 78
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 76
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10169
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, NULL, 'y')
SELECT @NewStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 77
SELECT @NewNextStateId = NewIdValue FROM @IDTable_State WHERE IdValue = 78
SELECT @NewRuleId = NewIdValue FROM @IDTable_Rules WHERE IdValue = 10167
exec usp_getNextId 'WorkflowTransition', @WorkflowTransitionId output 
INSERT INTO WorkflowTransition VALUES (@WorkflowTransitionId, @WorkflowId, @NewStateId, @NewNextStateId, @NewRuleId, @SystemUserId, 'Nov 16 2006 12:50:44:057AM', @SystemUserId, 'Nov 16 2006 12:50:44:057AM', 'Nov 16 2006 12:50:44:057AM', NULL, NULL, 'y')
 
-- Activate the workflow
UPDATE Workflow SET work_Enabled = 'Y' WHERE work_WorkflowId = @WorkflowId
 
-- **************  SCRIPTING Customer Care Workflow COMPLETE ***************
 
 
