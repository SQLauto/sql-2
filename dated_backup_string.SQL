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


--ASPNET_ACTIVITIES_backup_2014_11_04_020001_7457129.bak
select @statement


--declare @runtime varchar(12)
--select @runtime =  convert(varchar(20),getdate(),112) + right('00' +convert(varchar(2),datepart(hh, getdate())),2) +right('00' +convert(varchar(2),datepart(mi, getdate())),2)
--select @runtime

/*
BACKUP LOG [xxx] TO  DISK = N'E:\Backup\xxx.bak' 
WITH NOFORMAT, NOINIT,  NAME = N'xxx-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
*
