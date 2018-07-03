SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ScriptObjects]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ScriptObjects]
GO

/* This procedure will script out all objects of one type so they can be recreated using a T-SQL Script

Created by Edgewood Solutions 11/18/04

Usage:

exec usp_ScriptObjects Alert -- scripts out all alerts
exec usp_ScriptObjects Job -- scripts out all jobs
exec usp_ScriptObjects Operator -- scripts out all operators

The only change needed in the script is the default directory to place these script files @directory

*/
CREATE PROCEDURE usp_ScriptObjects @objecttype VARCHAR(50) = NULL AS

DECLARE @objectname  sysname, @filename VARCHAR(255), @directory VARCHAR(256)

SELECT @directory = "C:\WSH\"

IF (@objecttype = 'Alert')
BEGIN
DECLARE objects_cursor CURSOR
   FOR SELECT name FROM msdb.dbo.sysalerts
END

IF (@objecttype = 'Operator')
BEGIN
DECLARE objects_cursor CURSOR
   FOR SELECT name FROM msdb.dbo.sysoperators
END

IF (@objecttype = 'Job')
BEGIN
DECLARE objects_cursor CURSOR
   FOR SELECT name FROM msdb.dbo.sysjobs
END


OPEN objects_cursor
FETCH NEXT FROM objects_cursor INTO @objectname

WHILE @@FETCH_STATUS = 0
BEGIN

       -- remove junk from name
       SELECT @filename = REPLACE(@objectname,' ','')
       SELECT @filename = REPLACE(@filename,':','')
       SELECT @filename = REPLACE(@filename,'''','')
       SELECT @filename = REPLACE(@filename,'.','')
       
       SELECT @filename = @directory + @objecttype + "-"+ @filename + ".sql"

       EXEC master.dbo.sp_ScriptObject 
       @ServerName = @@SERVERNAME, 
       @DBName = '', 
       @ObjectName = @objectname, 
       @ObjectType = @objecttype, 
       @TableName = '',
       @ScriptFile = @filename

   FETCH NEXT FROM objects_cursor
   INTO @objectname
END

CLOSE objects_cursor
DEALLOCATE objects_cursor
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO