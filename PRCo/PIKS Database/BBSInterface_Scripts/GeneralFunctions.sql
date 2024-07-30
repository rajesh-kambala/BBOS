/* 
  Determines if the specified interface is currently executing
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_IsInterfaceExecuting]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_IsInterfaceExecuting]
GO
CREATE FUNCTION dbo.ufn_IsInterfaceExecuting(@InterfaceID int)
RETURNS int  AS  
BEGIN 

	DECLARE @IsExecuting int, @ID int
	SET @IsExecuting = 0

	-- Make sure we update the most recent
	-- record.  There may be multiple
	-- due to errors.
	SELECT @ID = MAX(ID)
	  FROM InterfaceStatus
     WHERE InterfaceID = @InterfaceID;

	IF @ID > 0 BEGIN
		SELECT @IsExecuting = IsExecuting
		  FROM InterfaceStatus
		 WHERE ID = @ID;
	END

	RETURN @IsExecuting
END
GO



/* 
   Returns a formatted name for the BBSInterface.  The names are truncated
   to fit the BBS data model.
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetFullName]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetFullName]
GO
CREATE FUNCTION dbo.ufn_GetFullName(@Pers_FirstName varchar(100), 
									@Pers_PRNickname1 varchar(100), 
									@Pers_MiddleName varchar(100), 
									@Pers_LastName varchar(100), 
									@Pers_Suffix varchar(100))
RETURNS varchar(500)  AS  
BEGIN 

	DECLARE @FullName varchar(500)

	SET @FullName  = 
			REPLACE(SUBSTRING(RTRIM(@Pers_FirstName),1 ,20)
			+ CASE WHEN @Pers_PRNickname1 IS NOT NULL THEN ' (' + RTRIM(@Pers_PRNickname1) + ')' ELSE '' END
			+ CASE WHEN @Pers_MiddleName IS NOT NULL THEN ' ' + SUBSTRING(RTRIM(@Pers_MiddleName),1 , 20) ELSE '' END 
			+ ' ' + SUBSTRING(RTRIM(@Pers_LastName),1 , 35)
			+ CASE WHEN @Pers_Suffix IS NOT NULL THEN ' ' + SUBSTRING(RTRIM(@Pers_Suffix),1 , 8) ELSE '' END, ' ,', ',')
	
	RETURN @FullName
END 
GO