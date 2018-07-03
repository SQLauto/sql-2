print ''
set nocount on
create table #versioninfo 
(   
    [Index] varchar(5), 
    [Name] varchar(20), 
    Internal_Value varchar(10), 
    Character_Value varchar(120)
)    
insert into #versioninfo exec ('xp_msver')

declare @sqlver varchar(10), 
                @winver varchar(10), 
                @cpuspeedcount varchar(3), 
                @Memory varchar(4), 
                @currentEditonstart varchar(3), 
                @Editionlength varchar(3), 
                @installdatestart varchar(10),
				@sqlname varchar(50)
set @sqlver = (select Character_Value from #versioninfo where Name = 'ProductVersion')
set @winver = (select Character_Value from #versioninfo where Name = 'WindowsVersion')
set @cpuspeedcount = (select Internal_Value from #versioninfo where Name = 'ProcessorCount')
set @Memory = (select Internal_Value from #versioninfo where Name = 'PhysicalMemory')
set @sqlname = CAST(SERVERPROPERTY('ServerName') as varchar(100))
create table #searchstring (location varchar(3))
insert into #searchstring values (charindex('Standard', @@version))
insert into #searchstring values (charindex('Enterprise', @@version))
insert into #searchstring values (charindex('Developer', @@version))
insert into #searchstring values (charindex('Personal', @@version))
insert into #searchstring values (charindex('desktop', @@version))
set @currentEditonstart = (select * from #searchstring where location > 0)
set @Editionlength = charindex('Edition', @@version) - @currentEditonstart + 7

create table #temp 
(
    Alternate_Name varchar(30),
    [Size] int,        
    Creation_Date varchar(15),
    Creation_Time varchar(10),
    Last_Written_Date varchar(10),
    Last_Written_Time varchar(10),
    Last_Accessed_Date varchar(10),
    Last_Accessed_Time varchar(10),
    Attributes int, 
    Rootpath varchar(100) 
)

/*  auto read registry for SQL installation root path, processor Identifier and speed */
DECLARE @root varchar(100), @cpuspeed int, @cpuidentifier varchar(100)
EXEC master..xp_regread 
        @rootkey='HKEY_LOCAL_MACHINE', 
        @key='SOFTWARE\Microsoft\MSSQLServer\setup', 
        @value_name='SQLPath', 
        @value = @root OUTPUT
EXEC master..xp_regread 
        @rootkey='HKEY_LOCAL_MACHINE', 
        @key='HARDWARE\DESCRIPTION\system\Centralprocessor\0', 
        @value_name='~MHz', 
        @value = @cpuspeed OUTPUT
EXEC master..xp_regread 
        @rootkey='HKEY_LOCAL_MACHINE', 
        @key='HARDWARE\DESCRIPTION\system\Centralprocessor\0', 
        @value_name='Identifier', 
        @value = @cpuidentifier OUTPUT

--  Insert the details of the root folder
insert into #temp (Alternate_Name, Size, Creation_Date, Creation_Time, Last_Written_Date, Last_Written_Time,
                                    Last_Accessed_Date, Last_Accessed_Time, Attributes) 
    exec ('xp_getfiledetails ''' + @root + '''')

--  Reformat the date of the root folder. We think the root folder represents the install date
update #temp set Rootpath = @root
set @installdatestart = (select substring(Creation_Date, 5, 2) + '/' +
                                                                substring(Creation_Date, 7, 2) + '/' +
                                                                substring(Creation_Date, 1, 4) from #temp)

select left(@sqlname, 25) as 'SQL_server_name', 
              case left(@sqlver, 4) 
              	    when '9.00' then 'SQL 2005' 
                    when '8.00' then 'SQL 2000' 
                    when '7.00' then 'SQL 7.0' 
                    when '6.50' then 'SQL 6.5' 
                    end + ' (' + 
             left(substring(@@version, cast( @currentEditonstart as int), cast( @Editionlength  as int)), 20) + ')' AS 'SQL_server_version',
            case substring (@sqlver, 6, 4) 
                -- 6.5
                when '121' then 'N/A'
                when '124' then 'SP1'
                when '139' then 'SP2'
                when '151' then 'SP3'
                when '201' then 'N/A'
                when '213' then 'SP1'
                when '240' then 'SP2'
                when '252' then 'SP3 ** bad **'
                when '258' then 'SP3'
                when '259' then 'SP3 + sbs'
                when '281' then 'SP4'
                when '297' then 'SP4 + sbs'
                when '339' then 'SP4 + y2k'
                when '415' then 'SP5 ** bad **'
                when '416' then 'SP5a'
                -- 7.0
                when '198' then 'beta 1'
                when '517' then 'beta 3'
                when '583' then 'rc1'
                when '623' then 'N/A'
                when '689' then 'SP1 beta'
                when '699' then 'SP1'
                when '835' then 'SP2 beta'
                when '842' then 'SP2'
                when '961' then 'SP3'
                when '1063' then 'SP4'
                -- 2000
                when '194' then 'N/A'
                when '384' then 'SP1'
                when '534' then 'SP2'
				when '760' then 'SP3'
                    else 'unknown ' 
                end 
                + ' (' + substring (@sqlver, 6, 4) + ')' as 'SQL_SP (Bld.)',
                case left(@winver, 4) 
                    when '5.0' then 'Windows 2000' 
                    when '4.0' then 'Windows NT 4.0' + '   ' 
                    end as 'Windows_version',
                case substring(@@version, (len(@@version) - 15), 14) 
                    when 'Service Pack 1' then 'SP1'
                    when 'Service Pack 2' then 'SP2'
                    when 'Service Pack 3' then 'SP3'
                    when 'Service Pack 4' then 'SP4'
                    when 'Service Pack 5' then 'SP5'
                    when 'Service Pack 6' then 'SP6'
                    when 'Service Pack 7' then 'SP7'
                    when 'Service Pack 8' then 'SP8' 
                    else 'N/A'
                    end + '    ' as 'OS_SP',             
                case substring(@cpuidentifier, 12, 2) 
                    when '15' then 'P4' 
                    when '6' then 'PIII' 
                    end + '(x' + @cpuspeedcount + ') ' + cast(@cpuspeed as varchar(4)) + ' MHz' as 'Processor(s)', 
                @Memory + ' MB ' as 'Memory',
                @installdatestart as 'Install_dt'

drop table #versioninfo
drop table #searchstring
drop table #temp

