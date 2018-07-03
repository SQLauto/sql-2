DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name

 
-- specify database backup directory
SET @path = 'E:\SQLBACKUPS\'  

 
-- specify filename format
--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112)
select @filedate = 'backup_' + 
CONVERT(varchar(4), datepart(yy, getdate()))+ '_' + 
right('0' + CONVERT(varchar(2), datepart(mm, getdate())),2)+ '_' + 
right('0' + CONVERT(varchar(2), datepart(dd, getdate())),2)+ '_' + 
right('0' + CONVERT(varchar(2), datepart(hour, getdate())),2)+
right('0' + CONVERT(varchar(2), datepart(minute, getdate())),2)+
right('0' + CONVERT(varchar(2), datepart(second, getdate())),2)+ '_' +
right('0' + CONVERT(varchar(6), datepart(MICROSECOND, getdate())),6) + '0' + '.bak'

 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb')  -- exclude these databases
order by name

 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

 
WHILE @@FETCH_STATUS = 0   
BEGIN   
       SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
       print'BACKUP DATABASE ' + @name + ' TO DISK = ' + char(39) + @fileName  + char(39)

       --BACKUP DATABASE @name TO DISK = @fileName  

 
       FETCH NEXT FROM db_cursor INTO @name   
END   

 
CLOSE db_cursor   
DEALLOCATE db_cursor


/*
set quoted_identifier off
declare @statement nvarchar(255)

select @statement = 'dbname_backup_' + 
CONVERT(varchar(4), datepart(yy, getdate()))+ '_' + 
right('0' + CONVERT(varchar(2), datepart(mm, getdate())),2)+ '_' + 
right('0' + CONVERT(varchar(2), datepart(dd, getdate())),2)+ '_' + 
right('0' + CONVERT(varchar(2), datepart(hour, getdate())),2)+
right('0' + CONVERT(varchar(2), datepart(minute, getdate())),2)+
right('0' + CONVERT(varchar(2), datepart(second, getdate())),2)+ '_' +
right('0' + CONVERT(varchar(6), datepart(MICROSECOND, getdate())),6) + '0' + 
'.bak'+"'"

*/