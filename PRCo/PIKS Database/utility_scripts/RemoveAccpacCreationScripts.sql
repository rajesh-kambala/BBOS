-- RemoveAccpacCreationScripts

-- This file removes the Accpac Creation stored procs used
-- during the PRCO Database Build process

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateTable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateTable]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateField]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateSelectField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateSelectField]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateTextField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateTextField]
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateKeyField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateKeyField]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateIntegerField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateIntegerField]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateNumericField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateNumericField]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateSearchSelectField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateSearchSelectField]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateMultiselectField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateMultiselectField]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateUserSelectField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateUserSelectField]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateAdvSearchSelectField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateAdvSearchSelectField]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateCheckboxField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateCheckboxField]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateDateTimeField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateDateTimeField]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateDateField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateDateField]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateEmailField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateEmailField]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateURLField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateURLField]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateMultilineField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateMultilineField]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateTeamField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateTeamField]
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateTerritoryField]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateTerritoryField]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateView]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateView]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_AccpacCreateDropdownValue]') 
                    and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_AccpacCreateDropdownValue]
GO

