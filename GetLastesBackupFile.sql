--SalesLogix_backup_200904090200.bak
SET NOCOUNT ON
declare @bkfile varchar(500)
create table #tmp 
(
	col1 varchar(500) null
)
insert #tmp (col1) exec xp_cmdshell 'dir /b /O-D \\cclprdslgx1\f$\SQLBackups\SqlBackupUser\SalesLogix_backup_*.bak'
select @bkfile = (select top 1 * from #tmp)
drop table #tmp
select @bkfile
