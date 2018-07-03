SET NOCOUNT ON

-- Get the name of all databases
DECLARE AllDatabases CURSOR FOR

SELECT name FROM master..sysdatabases
   where name not in ('master','tempdb', 'model', 'msdb', 'Northwind', 'pubs')

-- Open Cursor
OPEN AllDatabases

-- Define variables needed
DECLARE @DB NVARCHAR(128)
DECLARE @COMMAND NVARCHAR(128)

-- Get First database
FETCH NEXT FROM AllDatabases INTO @DB

-- Process until no more databases
WHILE (@@FETCH_STATUS = 0)
BEGIN

-- Build command to put database into DDBO ONLY mode
  --set @command ='master..sp_dboption @dbname=''' + @db +
  --              ''',@optname=''DBO USE ONLY'', @optvalue=''TRUE'''
  --  set @command ='master..sp_dboption @dbname=''' + @db +
  --              ''',@optname=''trunc. log on chkpt.'', @optvalue=''TRUE'''
    --set @command ='ALTER DATABASE [' + @db + '] SET RECOVERY SIMPLE WITH NO_WAIT'
    
    set @command ='USE ' + @db + ' EXEC dbo.sp_changedbowner @loginame = N''sa'', @map = false'
    
    


-- Print command to be processed
  print @command

-- Process Command
  --exec (@command)

-- Get next database
  FETCH NEXT FROM AllDatabases INTO @DB

END

-- Close and Deallocate Cursor
CLOSE AllDatabases
DEALLOCATE AllDatabases

