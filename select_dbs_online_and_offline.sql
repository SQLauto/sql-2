set nocount on
declare @Pserver varchar(100) 
set @Pserver = N'"$(Pserver)"' 
select @Pserver, a.name, b.state as 'Online_Offline' from master..sysdatabases a 
join sys.databases b on
a.name = b.name 
where a.dbid > 4 and b.state in (0,6) 
order by a.name 