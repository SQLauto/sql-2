---This will sync the users for a specific database. Get current in that database (USE database name) and run this script on the current database to sync SQL Server database users with their respective logins. 
--- If the login does not exist, an error message indicating that the login was not found will be generated.
DECLARE @UserName nvarchar(255)
DECLARE @SQLCmd nvarchar(511)
DECLARE orphanuser_cur cursor for
SELECT UserName = name
FROM sysusers
WHERE issqluser = 1 and (sid is not null and sid <> 0x0) 
                and suser_sname(sid) is null
ORDER BY name

OPEN orphanuser_cur
FETCH NEXT FROM orphanuser_cur INTO @UserName

WHILE (@@fetch_status = 0)
BEGIN
PRINT @UserName + ' user name being resynced'
-- PRINT @UserName
-- *************   Uncomment next line to work   *************************
-- SQL Server 2008 statement that can be used to replace the sp_change_users_login stored procedure
-- Note: The sp_change_users_login stored procedure will be deprecated in a future version of SQL Server

set @SQLCmd = 'ALTER USER '+@UserName+' WITH LOGIN = '+@UserName
 
EXEC (@SQLCmd)

FETCH NEXT FROM orphanuser_cur INTO @UserName
END

CLOSE orphanuser_cur
DEALLOCATE orphanuser_cur

GO
