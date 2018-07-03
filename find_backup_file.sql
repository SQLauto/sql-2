

--

--

-- This stored procedure was written by Greg Larsen for Washington State Department of Health.

-- Date: 02/28/2002

--

-- Description:

--  This stored procedure generates a list of files that need to be restored

--  should the server need to be rebuild.  The list only contains a list of database

--  backup files.

--

-- Declare variables used in SP

declare @cmd nvarchar (1000) 

declare @cmd1 nvarchar (1000) 

declare @db nvarchar(128)

declare @filename nvarchar(128)

declare @cnt int

declare @num_processed int

declare @name nvarchar(128) 

declare @physical_device_name nvarchar(128) 

declare @backup_start_date datetime

declare @type char(1) 

-- Section A --------------------------------------------

-- Turn off the row number message

set nocount on

-- Define cursor to hold all the different databases for the restore script will be built

declare db cursor for 

select name from master..sysdatabases

where name not in ('tempdb')

and name = 'MAPS_TRAINING'

-- Create a global temporary table that will hold the name of the backup, the database name,

-- and the type of database backup.

create table ##backupnames (

name nvarchar(100), 

database_name nvarchar(100), 

type char(1) )

-- Open cursor containing list of database names.

open db

fetch next from db into @db

-- Process until no more databases are left

WHILE @@FETCH_STATUS = 0

BEGIN

-- Subsection 1A ----------------------------------------------

-- initialize the physical device name

 set @physical_device_name = ""

-- get the name of the last full database backup

 select @physical_device_name = physical_device_name , @backup_start_date = backup_start_date

 from  msdb..backupset a join msdb..backupmediaset b on a.media_set_id = b.media_set_id

      join msdb..backupmediafamily c on a.media_set_id = c.media_set_id 

       where type='d' and backup_start_date = 

        (select top 1 backup_start_date from msdb..backupset 

             where @db = database_name and type = 'd'

              order by backup_start_date desc)  

-- Did a full database backup name get found 

if @physical_device_name <> "" 

begin

-- Build command to place a record in table that holds backup names

  select @cmd = 'insert into ##backupnames values (' + char(39) + 

              @physical_device_name + char(39) + ',' + char(39) + @db + char(39) + "," +

              char(39) + 'd' + char(39)+ ')'     

-- Execute command to place a record in table that holds backup names      

  exec sp_executesql @cmd

end

-- Subsection 1B ----------------------------------------------

-- Reset the physical device name 

set @physical_device_name = ""

-- Find the last differential database backup

 select @physical_device_name = physical_device_name, @backup_start_date = backup_start_date 

 from  msdb..backupset a join msdb..backupmediaset b on a.media_set_id = b.media_set_id

      join msdb..backupmediafamily c on a.media_set_id = c.media_set_id 

       where type='i' and backup_start_date = 

        (select top 1 backup_start_date from msdb..backupset 

             where @db = database_name and type = 'I' and backup_start_date > @backup_start_date 

              order by backup_start_date desc) 

-- Did a differential backup name get found

if @physical_device_name <> "" 

begin

-- Build command to place a record in table that holds backup names

  select @cmd = 'insert into ##backupnames values (' + char(39) + 

              @physical_device_name + char(39) + ',' + char(39) + @db + char(39) + "," +

              char(39) + 'i' + char(39)+ ')'     

-- Execute command to place a record in table that holds backup names        

  exec sp_executesql @cmd

end

-- Subsection 1B ----------------------------------------------

-- Build command to place records in table to hold backup names for all 

-- transaction log backups from the last database backup

set @CMD = "insert into ##backupnames select physical_device_name," + char(39) + @db + char(39) + 

           "," + char(39) + "l" + char(39) +   

 "from  msdb..backupset a join msdb..backupmediaset b on a.media_set_id = b.media_set_id " + 

 "join msdb..backupmediafamily c on a.media_set_id = c.media_set_id " +  

       "where type=" + char(39) + "l" + char(39) + "and backup_start_date >  @backup_start_dat and" + 

char(39) + @db + char(39) + " = database_name"

-- Execute command to place records in table to hold backup names 

-- for all transaction log backups from the last database backup

exec sp_executesql @cmd,@params=N'@backup_start_dat datetime', @backup_start_dat = @backup_start_date

-- get next database to process 

fetch next from db into @db

end

-- close and deallocate database list cursor

close db

deallocate db

-- Section B -------------------------------------------------------

-- define cursor for all database and log backups 

declare backup_name cursor for 

   select name,type from ##backupnames 

-- Open cursor containing list of database backups for specific database being processed  

open backup_name

-- Get first database backup for specific database being processed

fetch next from backup_name into @physical_device_name, @type

-- Set counter to track the number of backups processed

set @NUM_PROCESSED = 0

-- Process until no more database backups exist for specific database being processed

WHILE @@FETCH_STATUS = 0

BEGIN

-- print file name to restore

   print @physical_device_name

-- Get next database backup to process

   fetch next from backup_name into @physical_device_name, @type

end 

-- Close and deallocate database backup name cursor for current database being processed

close backup_name

deallocate backup_name

 

-- Drop global temporary table 

drop table ##backupnames

 

