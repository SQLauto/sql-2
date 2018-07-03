exec('drop table #loginfo')
go
exec('drop table #logfiles')
go

declare @target_percent int,	--. default = 0. Target percentage of remaining shrinkable space. Defaults to max possible.
@target_size_MB	int,			--. default = 10. Target size of final log in MB.
@max_iterations int,			--. default = 1000. Number of loops (max) to run proc through.
@backup_log_opt nvarchar(1000)		--. default = 'with truncate_only'. Backup options.

    set @target_percent = 5
    set @target_size_MB  = 10
    set @max_iterations  = 10
    set @backup_log_opt = 'with truncate_only'


declare @db         sysname, 
        @last_row   int,
        @log_size   decimal(15,2),
        @unused1    decimal(15,2),
        @unused     decimal(15,2),
        @shrinkable decimal(15,2),
        @iteration  int,
	@file_max   int,
	@file	    int,
	@fileid     varchar(5)

select  @db = db_name(),
        @iteration = 0

create table #loginfo ( 
    id          int identity, 
    FileId      int, 
    FileSize    numeric(22,0), 
    StartOffset numeric(22,0), 
    FSeqNo      int, 
    Status      int, 
    Parity      smallint, 
    --CreateTime  datetime 
    CreateTime nvarchar(127)
)

create unique clustered index loginfo_FSeqNo on #loginfo ( FSeqNo, StartOffset )

create table #logfiles ( id int identity(1,1), fileid varchar(5) not null )
insert #logfiles ( fileid ) select convert( varchar, fileid ) from sysfiles where status & 0x40 = 0x40        
select @file_max = @@rowcount

if object_id( 'table_to_force_shrink_log' ) is null
	exec( 'create table table_to_force_shrink_log ( x nchar(3000) not null )' )

insert  #loginfo ( FileId, FileSize, StartOffset, FSeqNo, Status, Parity, CreateTime ) exec ( 'dbcc loginfo' )
select  @last_row = @@rowcount

select  @log_size = sum( FileSize ) / 1048576.00,
        @unused = sum( case when Status = 0 then FileSize else 0 end ) / 1048576.00,
        @shrinkable = sum( case when id < @last_row - 1 and Status = 0 then FileSize else 0 end ) / 1048576.00
from    #loginfo

select  @unused1 = @unused -- save for later

select  'iteration'          = @iteration,
        'log size, MB'       = @log_size,
        'unused log, MB'     = @unused,
        'shrinkable log, MB' = @shrinkable,
        'shrinkable %'       = convert( decimal(6,2), @shrinkable * 100 / @log_size )

while @shrinkable * 100 / @log_size > @target_percent 
  and @shrinkable > @target_size_MB 
  and @iteration < @max_iterations begin
    select  @iteration = @iteration + 1 -- this is just a precaution

    exec( 'insert table_to_force_shrink_log select name from sysobjects
           delete table_to_force_shrink_log')

    select @file = 0
    while @file < @file_max begin
        select @file = @file + 1
        select @fileid = fileid from #logfiles where id = @file
        exec( 'dbcc shrinkfile( ' + @fileid + ' )' )
    end

    exec( 'backup log [' + @db + '] ' + @backup_log_opt )

    truncate table #loginfo 
    insert  #loginfo ( FileId, FileSize, StartOffset, FSeqNo, Status, Parity, CreateTime ) exec ( 'dbcc loginfo' )
    select  @last_row = @@rowcount

    select  @log_size = sum( FileSize ) / 1048576.00,
            @unused = sum( case when Status = 0 then FileSize else 0 end ) / 1048576.00,
	    @shrinkable = sum( case when id < @last_row - 1 and Status = 0 then FileSize else 0 end ) / 1048576.00
    from    #loginfo

    select  'iteration'          = @iteration,
            'log size, MB'       = @log_size,
            'unused log, MB'     = @unused,
            'shrinkable log, MB' = @shrinkable,
            'shrinkable %'       = convert( decimal(6,2), @shrinkable * 100 / @log_size )
end

if @unused1 < @unused 
select  'After ' + convert( varchar, @iteration ) + 
        ' iterations the unused portion of the log has grown from ' +
        convert( varchar, @unused1 ) + ' MB to ' +
        convert( varchar, @unused ) + ' MB.'
union all
select	'Since the remaining unused portion is larger than 10 MB,' where @unused > 10
union all
select	'you may try running this procedure again with a higher number of iterations.' where @unused > 10
union all
select	'Sometimes the log would not shrink to a size smaller than several Megabytes.' where @unused <= 10

else
select  'It took ' + convert( varchar, @iteration ) + 
        ' iterations to shrink the unused portion of the log from ' +
        convert( varchar, @unused1 ) + ' MB to ' +
        convert( varchar, @unused ) + ' MB'

exec( 'drop table table_to_force_shrink_log' )

