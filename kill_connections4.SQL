/********** Kills all connections in all user databases  **********************/
SET NOCOUNT ON
USe master
go

DECLARE C1 CURSOR
READ_ONLY
FOR select name from sysdatabases where dbid > 4

DECLARE @name varchar(40)
OPEN C1

FETCH NEXT FROM C1 INTO @name
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		DECLARE @SpId INT,@DbId INT,@Connects INT,@KillStmt VARCHAR(40)

		/**/ SET @DbId=DB_ID(@name) /* Set the Database Name here*/

		SELECT @SpId =MIN(SpId),@Connects=COUNT(SpId) FROM MASTER.SYS.SYSPROCESSES (NOLOCK) 
		WHERE DbId=@DbId

		SELECT LogiName,* FROM MASTER.SYS.SYSPROCESSES (NOLOCK) WHERE DbId=@DbId

		if (@Connects > 0)
		begin
			PRINT 'There are Currently '+ CAST(@Connects AS CHAR(3)) +' Sessions connected to the " '+
			DB_NAME(@DbId)+'" Database'

			WHILE @SpId IS NOT NULL
			BEGIN
				SET @KillStmt='KILL '+ CAST(@SpId AS CHAR(3))
				EXEC(@KillStmt)
				--print @KillStmt
				SELECT @SpId =MIN(SpId) FROM MASTER.SYS.SYSPROCESSES (NOLOCK) 
				WHERE DbId=@DbId AND SpId>@SpId
				SELECT @Connects=COUNT(SpId) FROM MASTER.SYS.SYSPROCESSES (NOLOCK) WHERE DbId=@DbId
			END
			PRINT ' Killed all the Connections to database '  + @name + CHAR(13)
		end
		


		SELECT @Connects=COUNT(SpId) FROM MASTER.SYS.SYSPROCESSES (NOLOCK) WHERE DbId=@DbId
		PRINT ' The Present Connections to database ' + @name + ' are: ' + CAST(@Connects AS CHAR(3))
		SELECT LogiName,* FROM MASTER.SYS.SYSPROCESSES (NOLOCK) WHERE DbId=@DbId

	END 
	FETCH NEXT FROM C1 INTO @name
END

CLOSE C1
DEALLOCATE C1
GO

