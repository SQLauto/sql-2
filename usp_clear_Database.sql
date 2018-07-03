if exists(select * from sys.objects where object_id = object_id('dbo.usp_clear_database') and type = 'P')
	drop procedure dbo.usp_clear_database
go

create procedure dbo.usp_clear_database
	@db_name sysname = null,
	@reset_ident tinyint = 1
as
begin
	set nocount on

	if @db_name is null
		set @db_name = db_name()

	if @reset_ident is null
		set @reset_ident = 0

	if not exists(select * from master.sys.databases where name = @db_name and database_id > 4)
	begin
		raiserror('Database does not exist or it can not be cleared', 16, 1)
		return
	end

	declare @recovery_mode sysname

	select @recovery_mode = cast(DatabasePropertyEx(@db_name,'Recovery') as sysname)

	if @recovery_mode <> 'Simple'
	begin
		declare @ncmd nvarchar(max)

		print '-- Changing database recovery mode to SIMPLE'

		set @ncmd = 'alter database [' + @db_name + '] set recovery simple'

		print @ncmd

		exec sp_executesql @ncmd
	end

	-------------------------------------------------------------------------------------------
	-- prepare table with tables list

	create table #temp_tables
	(
		rec_id int identity(1, 1) primary key not null,
		schema_name sysname not null,
		table_name sysname not null
	)

	declare @n_cmd nvarchar(max)

	set @n_cmd = 'insert into #temp_tables (schema_name, table_name) select ss.name as schema_name, st.name as table_name from [' + @db_name + '].sys.tables as st inner join [' + @db_name + '].sys.schemas as ss on ss.schema_id = st.schema_id where ss.name <> ''sys'' '

	exec sp_executesql @n_cmd

	-------------------------------------------------------------------------------------------
	-- disable constraints

	declare @table_name sysname
	declare @schema_name sysname
	declare @counter_max int
	declare @counter int

	select @counter_max = max(rec_id) from #temp_tables

	if @counter_max is null
		set @counter_max = 0

	declare @object_name nvarchar(max)

	set @counter = @counter_max
	while @counter > 0
	begin
		set @table_name = null
		set @schema_name = null

		select @table_name = table_name, @schema_name = schema_name from #temp_tables where rec_id = @counter

		if @table_name is null or @schema_name is null
			break

		set @object_name = N'[' + @db_name + N'].[' + @schema_name + N'].[' + @table_name + N']'

		set @n_cmd = N'alter table ' + @object_name + N' nocheck constraint all'

		print @n_cmd

		begin try
			exec sp_executesql @n_cmd
		end try
		begin catch
			print '-------------------------------------------------------------------------'
			print 'ERROR - Could not disable constraints for table ' + @object_name
			print error_message()
			print '-------------------------------------------------------------------------'
		end catch

		set @counter = @counter - 1
	end

	----------------------------------------------------------------------------------------------
	-- delete records from tables

	set @counter = @counter_max
	while @counter > 0
	begin
		set @table_name = null
		set @schema_name = null

		select @table_name = table_name, @schema_name = schema_name from #temp_tables where rec_id = @counter

		if @table_name is null or @schema_name is null
			break

		set @object_name = N'[' + @db_name + N'].[' + @schema_name + N'].[' + @table_name + N']'

		set @n_cmd = 'delete ' + @object_name

		print @n_cmd

		begin try
			exec sp_executesql @n_cmd

			if @reset_ident = 1
			begin
				set @n_cmd = 'if exists(select * from [' + @db_name + '].sys.columns where object_id = object_id(''' + @object_name + ''') and is_identity = 1) dbcc checkident(''' + @object_name + ''', reseed, 0)'

				print @n_cmd

				exec sp_executesql @n_cmd
			end
		end try
		begin catch
			print '-------------------------------------------------------------------------'
			print 'ERROR - Could not clean table ' + @object_name
			print error_message()
			print '-------------------------------------------------------------------------'
		end catch

		set @counter = @counter - 1
	end

	-----------------------------------------------------------------------------------------------
	-- enable constraints

	set @counter = @counter_max
	while @counter > 0
	begin
		set @table_name = null
		set @schema_name = null

		select @table_name = table_name, @schema_name = schema_name from #temp_tables where rec_id = @counter

		if @table_name is null or @schema_name is null
			break

		set @n_cmd = 'alter table [' + @db_name + '].[' + @schema_name + '].[' + @table_name + '] with check check constraint all'

		print @n_cmd

		begin try
			exec sp_executesql @n_cmd
		end try
		begin catch
			print '-------------------------------------------------------------------------'
			print 'ERROR - Could not enable constraints for table ' + @object_name
			print error_message()
			print '-------------------------------------------------------------------------'
		end catch

		set @counter = @counter - 1
	end

	drop table #temp_tables

	---------------------------------------------------------------------------------------------------
	-- restore database recovery mode

	if @recovery_mode <> 'Simple'
	begin
		declare @ncmd2 nvarchar(max)

		print '-- Restoring database recovery mode'

		set @ncmd2 = 'alter database [' + @db_name + '] set recovery ' + @recovery_mode

		print @ncmd2

		exec sp_executesql @ncmd2
	end

end
go
