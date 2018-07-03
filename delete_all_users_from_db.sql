use pubs2
go

--============================================
DECLARE DELETEUSERS CURSOR
READ_ONLY
FOR SELECT name FROM sysusers WHERE issqlrole = 0 AND uid > 2 

DECLARE @name varchar(40)
OPEN DELETEUSERS

FETCH NEXT FROM DELETEUSERS INTO @name
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT 'User: ' + @name
		EXEC sp_revokedbaccess @name
		--SELECT @name
		--print 'deleted ' + @name

	END
	FETCH NEXT FROM DELETEUSERS INTO @name
END

CLOSE DELETEUSERS
DEALLOCATE DELETEUSERS
GO

