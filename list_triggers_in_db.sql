declare @dbname as sysname
declare @sql nvarchar(4000)
declare @tn as smallint
declare @trn as smallint

set @dbname = db_name()

set @sql = N'
select 	@t = max(datalength(rtrim(cast(object_name(o.parent_obj) as char)))), 
	@tr = max(datalength(rtrim(cast(o.[name] as char))))
from ' + @dbname + '..sysobjects o
where	OBJECTPROPERTY(o.[id], ''IsTrigger'') = 1'

execute sp_executesql @sql, N'@t smallint output, @tr smallint output', @t=@tn output, @tr=@trn output

set @sql = N'
select 	cast(object_name(o.parent_obj) as char(' + str(@tn) + ')) as Parent_Name,
	case 
		when OBJECTPROPERTY(o.parent_obj, ''IsTable'') = 1 then ''Table''
		when OBJECTPROPERTY(o.parent_obj, ''IsView'') = 1 then ''View''
		else ''''
		end as Parent_Type,
	cast(o.[name] as char(' + str(@trn) + ')) as [Name],
	case 
		when (	select cmptlevel 
			from master.dbo.sysdatabases
	      		where [name] = db_name()) = 80 then 
			case 
				when OBJECTPROPERTY(o.[id], ''ExecIsInsteadOfTrigger'') = 1 then ''Instead Of Trigger''
				else ''After Trigger''
				end
	 	else ''After Trigger'' 
		end as [Type],
	case 	
		when OBJECTPROPERTY(o.[id], ''ExecIsInsertTrigger'') = 1 then ''X''
		else '''' 
	end as [Insert],
	case 	
		when OBJECTPROPERTY(o.[id], ''ExecIsUpdateTrigger'') = 1 then ''X''
		else '''' 
	end as [Update],
	case 	
		when OBJECTPROPERTY(o.[id], ''ExecIsDeleteTrigger'') = 1 then ''X''
		else '''' 
	end as [Delete],
	case 	
		when OBJECTPROPERTY(o.[id], ''ExecIsFirstInsertTrigger'') = 1 then ''X''
		else '''' 
	end as [IsFirstInsertTrigger]
	,
	case 	
		when OBJECTPROPERTY(o.[id], ''ExecIsFirstUpdateTrigger'') = 1 then ''X''
		else ''''
	end as [IsFirstUpdateTrigger]
	, 
	case 	
		when OBJECTPROPERTY(o.[id], ''ExecIsFirstDeleteTrigger'') = 1 then ''X''
		else ''''
	end as [IsFirstDeleteTrigger],
	case 	
		when OBJECTPROPERTY(o.[id], ''ExecIsLastInsertTrigger'') = 1 then ''X''
		else '''' 
	end as [IsLastInsertTrigger]
	,
	case 	
		when OBJECTPROPERTY(o.[id], ''ExecIsLastUpdateTrigger'') = 1 then ''X''
		else ''''
	end as [IsLastUpdateTrigger]
	, 
	case 	
		when OBJECTPROPERTY(o.[id], ''ExecIsLastDeleteTrigger'') = 1 then ''X''
		else ''''
	end as [IsLastDeleteTrigger]
from ' + @dbname + '..sysobjects o
WHERE	OBJECTPROPERTY(o.[id], ''IsTrigger'') = 1
order by object_name(o.parent_obj), o.[name]'

execute sp_executesql @sql






