/********** Powered By : VAMPIRE **********************/
SET NOCOUNT ON

DECLARE @SpId INT,@DbId INT,@Connects INT,@KillStmt VARCHAR(40)

/**/ SET @DbId=DB_ID('Enter_Your_DB_NAME_Here') /* Set the Database Name here*/

SELECT @SpId =MIN(SpId),@Connects=COUNT(SpId) FROM MASTER.SYS.SYSPROCESSES (NOLOCK) 
WHERE DbId=@DbId

SELECT LogiName,* FROM MASTER.SYS.SYSPROCESSES (NOLOCK) WHERE DbId=@DbId

PRINT 'There are Currently '+ CAST(@Connects AS CHAR(3)) +' Sessions connected to the " '+
DB_NAME(@DbId)+'" Database'

WHILE @SpId IS NOT NULL
BEGIN
	SET @KillStmt='KILL '+ CAST(@SpId AS CHAR(3))
	EXEC(@KillStmt)
	SELECT @SpId =MIN(SpId) FROM MASTER.SYS.SYSPROCESSES (NOLOCK) 
	WHERE DbId=@DbId AND SpId>@SpId
	SELECT @Connects=COUNT(SpId) FROM MASTER.SYS.SYSPROCESSES (NOLOCK) WHERE DbId=@DbId
END

PRINT ' Killed all the Connections to the said Database' + CHAR(13)
SELECT @Connects=COUNT(SpId) FROM MASTER.SYS.SYSPROCESSES (NOLOCK) WHERE DbId=@DbId
PRINT ' The Present Connections to this Database are: ' + CAST(@Connects AS CHAR(3))
SELECT LogiName,* FROM MASTER.SYS.SYSPROCESSES (NOLOCK) WHERE DbId=@DbId



