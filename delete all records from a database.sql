/*****************************************************************************************************************************************
*
* Author  Rafal Skotak
* Purpose This procedure deletes all records from all tables in the specified database 
*         (except schema 'sys' and databases master, model, tempdb and msdb)
*         At first all constraints are disabled, afterwards all records are deleted 
*         (truncate would not work due to foreign keys) and 
*         finally all constraints are enabled
* Date    2008.01.31
*
******************************************************************************************************************************************/


if exists(select * from sys.objects where object_id = object_id('dbo.proc_clear_database') and type = 'P')
	drop procedure dbo.proc_clear_database;
go

create procedure dbo.proc_clear_database
	@db_name sysname = null
as
begin
	set nocount on

	if @db_name is null
		set @db_name = db_name()

	if not exists(select * from master.sys.databases where name = @db_name and database_id > 4)
	begin
		raiserror('Database does not exist or it can not be truncated', 16, 1)
		return
	end

	-------------------------------------------------------------------------------------------
	-- prepare table with tables list

	create table #temp_tables
	(
		schema_name sysname not null,
		table_name sysname not null
	)

	declare @n_cmd nvarchar(max)

	set @n_cmd = 'insert into #temp_tables select ss.name as schema_name, st.name as table_name from [' + @db_name + '].sys.tables as st inner join [' + @db_name + '].sys.schemas as ss on ss.schema_id = st.schema_id where ss.name <> ''sys'' '

	exec sp_executesql @n_cmd

	-------------------------------------------------------------------------------------------
	-- disable constraints

	declare @table_name sysname
	declare @schema_name sysname

	declare database_tables cursor local read_only for 
	select
		table_name, 
		schema_name
	from 
		#temp_tables

	open database_tables

	fetch next from database_tables into @table_name, @schema_name

	while @@fetch_status = 0
	begin
		set @n_cmd = 'alter table [' + @db_name + '].[' + @schema_name + '].[' + @table_name + '] nocheck constraint all'

		print @n_cmd

		exec sp_executesql @n_cmd

		fetch next from database_tables into @table_name, @schema_name
	end

	close database_tables

	----------------------------------------------------------------------------------------------
	-- delete records from tables

	open database_tables

	fetch next from database_tables into @table_name, @schema_name

	while @@fetch_status = 0
	begin
		set @n_cmd = 'delete [' + @db_name + '].[' + @schema_name + '].[' + @table_name + ']'

		print @n_cmd

		exec sp_executesql @n_cmd

		fetch next from database_tables into @table_name, @schema_name
	end

	close database_tables
	
	-----------------------------------------------------------------------------------------------
	-- enable constraints


	open database_tables

	fetch next from database_tables into @table_name, @schema_name

	while @@fetch_status = 0
	begin
		set @n_cmd = 'alter table [' + @db_name + '].[' + @schema_name + '].[' + @table_name + '] with check check constraint all'

		print @n_cmd

		exec sp_executesql @n_cmd

		fetch next from database_tables into @table_name, @schema_name
	end

	close database_tables

	deallocate database_tables

	drop table #temp_tables
end
go

-- example:

exec dbo.proc_clear_database 'AdventureWorks'





