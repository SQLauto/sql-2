if @@servername is null or @@servername <> Convert(sysname,SERVERPROPERTY('ServerName')) 
begin 
        Print 'Servername is not, set attempting to fix' 
        declare @OldName sysname,@NewName sysname 
        select @OldName = srvname from master.dbo.sysservers where srvid = 0 --This is how "local" is defined in SP_ADDServer

        if @OldName is not null and @OldName <> '' 
        begin 
                Exec sp_dropserver @OldName 
        end 
                
        set @NewName = Convert(sysname,SERVERPROPERTY('ServerName')) 
        Exec sp_addserver @NewName,'local' 
        select @@servername 

        RAISERROR ('Servername has been reset please restart your SQL Server service and re-run DB_Setup',16,-1) 
end 
else 
begin 
        Print 'Servername is correctly set' 
        Print Convert(sysname,SERVERPROPERTY('ServerName')) 
end


------
--
/* small version
declare @NewName sysname 
set @NewName = Convert(sysname,SERVERPROPERTY('ServerName')) 
Exec sp_addserver @NewName,'local' 
*/

 