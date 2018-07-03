EXECUTE master.dbo.xp_delete_file    
    0,
    N'**FILEPATH OF OLD BACKUPS LOCATION**',
    N'bak',
    N'**DATE BEFORE WHICH YOU DONT WANT TO KEEP BACKUPS** T **TIME**',
    1 ;
    
    
/* -- sample use

declare @twodays varchar(100)
select @twodays = cast(getdate() - 2 as varchar(100))
select @twodays

EXECUTE master.dbo.xp_delete_file    
    0,
    --N'H:\SQLBACKUPS',
	N'\\Ccltstecosqldb1\sqlbackups',
    N'bak',
    @twodays,
    1 ;



*/