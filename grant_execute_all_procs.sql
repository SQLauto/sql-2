print 'SCRIPT TO ASSIGN EXECUTE RIGHTS FOR STORED PROCEDURES'
DECLARE @SPName varchar(100)
DECLARE @cmd NVARCHAR(500)

/* CREATE A NEW ROLE */
print ''
print '1/2 ADD ROLE:'
if not exists (select 'RoleName' = name, 'RoleId' = uid, 'IsAppRole' = isapprole
        from sysusers where (issqlrole = 1 or isapprole = 1) and name = 'db_executor')
        begin
                CREATE ROLE db_executor
                print '  Role Added - db_executor'
        end
        else
                print '  Role Exists - db_executor'

/* GRANT EXECUTE FOR EACH SP TO THE ROLE */
print ''
print '2/2 GRANT EXECUTE RIGHTS TO:'
--GRANT Execute to db_executor

DECLARE SP_csr CURSOR FOR 
        select name from sys.procedures where is_ms_shipped=0 
        /* and left(name,2) in ('gl','gs','ps','ts')  */
-- uncomment the line above and amend the own filtering if you only wish to grant execute rights on certain SP masks.
        order by name
        
OPEN SP_csr

FETCH NEXT FROM SP_csr into @SPName

   WHILE @@FETCH_STATUS = 0   
   BEGIN  
       SET @cmd = 'GRANT EXECUTE ON dbo.' + @SPName + ' TO db_executor'
       EXEC (@cmd)  
           print '  Grant db_executor - dbo.' + @SPName
        FETCH NEXT FROM SP_csr into @SPName   
   END

   CLOSE SP_csr   
   DEALLOCATE SP_csr 

Print ''
print 'Script Completed'
