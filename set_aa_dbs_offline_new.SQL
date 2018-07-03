set nocount on
select '--SQL Server: ' + @@SERVERNAME
select ' /* version: ' + @@version + ' */'


use master;
declare @nsql nvarchar(max);
select @nsql=coalesce(@nsql+CHAR(13)+CHAR(10),'')+
'ALTER DATABASE ['+name+'] SET OFFLINE WITH NO_WAIT;'
from master..sysdatabases where sid <> 0x01
print @nsql
--exec (@nsql)