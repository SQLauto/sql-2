IF EXISTS (SELECT name 
       FROM   sysobjects 
       WHERE  name = N'up_AllProcPermissionsForDB' 
       AND    type = 'P')
    DROP PROCEDURE up_AllProcPermissionsForDB
GO

CREATE PROCEDURE up_AllProcPermissionsForDB 
    @db sysname, 
    @ProcLike varchar(50) = 'up_', -- used (like) in where clause
    @Revoke bit = 0 -- if 1 then will revoke permissions instead of granting
AS


set nocount on
if isnull(@db,'') = '' BEGIN
    RAISERROR('The parameter ''%s'' was not supplied.',12,1,'db') WITH NOWAIT
    RETURN(1)
END
--revoke & proclike parameters can't be null
set @revoke = Isnull(@revoke,0)
set @ProcLike = Isnull(@ProcLike,'')
if right(@ProcLike,1) <> '%'
    set @ProcLike = @ProcLike + '%'

declare @proc varchar (1000)
declare @user varchar(200)
DECLARE @Exec Nvarchar(4000)
create table #tmpUsers (
    [User] nvarchar(150)
)
create table #tmpProcs (
    [Proc] nvarchar(150)
)
    insert #tmpUsers  
    exec ('select name  
    from ' + @db + '.dbo.sysusers
    where 
    name not in (''dbo'',''guest'',''public'')
    and 
    name not like ''db_%''')


    insert #tmpProcs  
    exec ('select name  
    FROM ' + @db + '.dbo.sysobjects 
    WHERE   type = ''p''
    and name like ''' + @ProcLike + '''
    order   by name')

DECLARE curExec CURSOR
READ_ONLY
FOR 
select [Proc], [user] from #tmpProcs, #tmpUsers

OPEN curExec

FETCH NEXT FROM curExec INTO @proc, @user
WHILE (@@fetch_status <> -1)
BEGIN
    IF (@@fetch_status <> -2)
    BEGIN
        IF @Revoke = 0
            SELECT @Exec = 'USE ' + @db + '; GRANT EXEC ON [DBO].[' + @proc + '] TO [' + @user + ']'
        ELSE
            SELECT @Exec = 'USE ' + @db + '; REVOKE EXEC ON [DBO].[' + @proc + '] TO [' + @user + ']'
        PRINT @Exec
        execute sp_executesql @Exec
    END
    FETCH NEXT FROM curExec INTO @proc, @user
END

CLOSE curExec
DEALLOCATE curExec

drop table #tmpUsers
drop table #tmpProcs


GO



