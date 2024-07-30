/***********************************************************************
***********************************************************************
 Copyright Travant Solutions, Inc. 2006

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Travant Solutions is 
 strictly prohibited.

 Confidential, Unpublished Property of Travant Solutions, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com.  

 Notes:	Adapted from code by mak mak_999@yahoo.com
        http://www.databasejournal.com/features/mssql/article.php/2174031

***********************************************************************
***********************************************************************/
If Exists (Select name from sysobjects where name = 'usp_KillDBProcesses' and type='P') Drop Procedure dbo.usp_KillDBProcesses
Go

CREATE PROCEDURE usp_KillDBProcesses
    @dbname varchar(128) 
AS

SET nocount on
SET quoted_identifier off

DECLARE @kill_id int
DECLARE @query varchar(320)

DECLARE killprocess_cursor CURSOR FOR 
SELECT a.spid 
  FROM sysprocesses a JOIN
       sysdatabases b ON a.dbid=b.dbid 
 WHERE b.name=@dbname

OPEN killprocess_cursor
FETCH NEXT FROM killprocess_cursor INTO @kill_id
WHILE (@@fetch_status =0) BEGIN
    SET @query = 'kill ' + convert(varchar,@kill_id)
    EXEC (@query)

    FETCH NEXT FROM killprocess_cursor INTO @kill_id
END

CLOSE killprocess_cursor
DEALLOCATE killprocess_cursor
Go