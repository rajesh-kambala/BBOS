if exists (select * from dbo.sysobjects 
			where id = object_id(N'[dbo].[usp_RefreshAllViews]') 
				and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_RefreshAllViews]
GO

CREATE PROCEDURE dbo.usp_RefreshAllViews
AS
BEGIN
  DECLARE @sql varchar(8000)
  SET @sql = ''

  DECLARE crs_SPs CURSOR FAST_FORWARD FOR 
        SELECT 'exec sp_refreshview ' + Name + ' '
            FROM sysObjects where xType = 'v' and name not in ('vPRLocation', 'vPRCompanyLocation') 
  OPEN crs_SPs      
  FETCH NEXT FROM  crs_SPs INTO @sql
  WHILE @@FETCH_STATUS = 0
  BEGIN
    exec (@sql)
    FETCH NEXT FROM  crs_SPs INTO @sql
  END

  CLOSE crs_SPs                    --Close cursor
  DEALLOCATE crs_SPs               --Deallocate cursor

END
GO
