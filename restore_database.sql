--skip this step, we have the daily backup
--backup database MAPS_MASTER to DISK = 'e:\SQLBackups\MAPS_MASTER.BAK' with INIT



declare @dbname varchar(50)
declare @backuplocation varchar(1000)
declare @s varchar(2000)

set @dbname = 'zzz_delete_me'	-- substitute your database name here
set @backuplocation = 'e:\SQLBackups\zzz_delete_me.BAK'

--kill connections----------------------------
--use master
--go
set nocount on
declare Users cursor for 
	select spid
	from master..sysprocesses 
	where db_name(dbid) = @dbname

declare @spid int, @str varchar(255)
set @str = ''
set @spid = 0
open Users
fetch next from Users into @spid
while @@fetch_status <> -1
begin
   if @@fetch_status = 0
   begin
      set @str = 'kill ' + convert(varchar, @spid)
      exec (@str)
      print @str
   end
   fetch next from Users into @spid
end
deallocate Users
--end of kill connections

SET @s = 'restore database ' + @dbname +  char(13) + char(10) + ' from DISK = ' + char(39)  + @backuplocation + char(39) + ' with replace' 
print ''
print @s
exec(@s)
