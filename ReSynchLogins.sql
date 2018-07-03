DECLARE @UserName nvarchar(255)
DECLARE orphanuser_cur cursor for
SELECT UserName = name
FROM sysusers
WHERE issqluser = 1 and (sid is not null and sid <> 0x0) and suser_sname(sid) is null
ORDER BY name  

--cannot translate sid to existing user=orphaned

OPEN orphanuser_cur
FETCH NEXT FROM orphanuser_cur INTO @UserName

WHILE (@@fetch_status = 0)
BEGIN
PRINT @UserName + ' user name being resynced'

EXEC sp_change_users_login 'Update_one', @UserName, @UserName

FETCH NEXT FROM orphanuser_cur INTO @UserName
END

CLOSE orphanuser_cur
DEALLOCATE orphanuser_cur
go


--Exec sp_MSForEachTable  "UPDATE STATISTICS ? with fullscan"
