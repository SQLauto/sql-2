declare @cStatement varchar(255)

declare G_cursor CURSOR for select "exec sp_change_users_login 'auto_fix'," + "'" + convert(varchar(64),name)+ "'"
 from sysusers
	

set nocount on
SET QUOTED_IDENTIFIER OFF
OPEN G_cursor
FETCH NEXT FROM G_cursor INTO @cStatement 
WHILE (@@FETCH_STATUS <> -1)
begin
	EXEC (@cStatement)
	FETCH NEXT FROM G_cursor INTO @cStatement 
end
DEALLOCATE G_cursor