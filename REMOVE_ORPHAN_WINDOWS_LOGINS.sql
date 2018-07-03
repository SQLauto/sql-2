
-- Query to print (list) Orphan Windows Logins
-- Orphan Windows Logins: Logins already removed 
-- from Active Directory (AD) but not from SQL Server. 
-- Use the generated output of this query to remove 
-- all Orphan Windows logins from a SQL Server Instance. 

SET NOCOUNT ON 
DECLARE @CMDCursor as CURSOR
DECLARE @CMD nvarchar(4000)

CREATE TABLE #Orphan_windows_logins
  (
     [sid]  VARBINARY(85),
     [name] SYSNAME
  )

INSERT #Orphan_windows_logins
EXEC sys.sp_validatelogins
 
SET @CMDCursor = CURSOR FOR
SELECT 'DROP LOGIN ' + ' [' + name + '] ' + CHAR(13) + 'GO' 
FROM   #Orphan_windows_logins
 
OPEN @CMDCursor

FETCH NEXT FROM @CMDCursor INTO @CMD

WHILE @@FETCH_STATUS = 0
BEGIN
 Print @CMD
 FETCH NEXT FROM @CMDCursor INTO @CMD
END

CLOSE @CMDCursor

DROP TABLE #Orphan_windows_logins 



