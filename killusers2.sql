--remember using from database to kill

declare @c cursor
declare @spid smallint

declare @execstr nvarchar(64)

set @c = cursor fast_forward read_only for
select spid from master..sysprocesses (nolock)
where dbid in (select dbid from sysdatabases where name = db_name())
and spid <> @@spid

open @c

fetch next from @c into @spid
while @@fetch_status = 0 begin
    set @execstr = N'kill ' + convert(varchar(5), @spid)
    --print @execstr
    exec sp_executesql @execstr
    fetch next from @c into @spid
end

close @c
deallocate @c
