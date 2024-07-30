if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_DTSPreExecute]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_DTSPreExecute]
GO

CREATE PROC dbo.usp_DTSPreExecute @TableName varchar(50), @DisableTriggers bit = 1
AS
BEGIN 
	IF (@DisableTriggers = 1)
	    Exec('ALTER TABLE ' + @TableName + ' DISABLE TRIGGER ALL');  
	DECLARE @SQL varchar(8000)
	SET @SQL = 'truncate table ' + @TableName
	Exec(@SQL)
END
GO

if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_DTSPostExecute]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[usp_DTSPostExecute]
GO

CREATE PROC dbo.usp_DTSPostExecute @TableName varchar(50), @PrimaryKeyName varchar(50)
AS
BEGIN
	DECLARE @SQL varchar(8000)
	SET @SQL = 'DECLARE @IDMax int' +
	' DECLARE @TableId int' +
	' DECLARE @RepRangeStart int' +
	' SELECT @TableId = Bord_TableId FROM custom_tables WHERE Bord_Caption = ' + '''' + @TableName + '''' +
	' SELECT @IDMax = Max(' + @PrimaryKeyName + ') FROM ' + @TableName +
	' SELECT @RepRangeStart = (((@IDMax / 500)+1)*500)'  +
	' If (@IDMax is not null)' +
	' BEGIN' +
	'    UPDATE Rep_Ranges ' +
	'      set Range_RangeStart = @RepRangeStart,' +
	'            Range_RangeEnd = @RepRangeStart + 499,' +
	'            Range_NextRangeStart = @RepRangeStart + 500,' +
	'            Range_NextRangeEnd = @RepRangeStart + 999,' +
	'            Range_Control_NextRange = @RepRangeStart + 1000' +
	'       WHERE Range_TableId = @TableId;' +
	'    UPDATE SQL_Identity set ID_NextId = @IDMax + 1 ' +
	'       WHERE ID_TableId = @TableId;' +
	' END'
	Exec(@SQL)
	Exec('ALTER TABLE ' + @TableName + ' ENABLE TRIGGER ALL');  
END
GO