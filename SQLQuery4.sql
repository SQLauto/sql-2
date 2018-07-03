
--kill users start
--kill users in current db

DECLARE @dbname varchar(50)
DECLARE @strSQL varchar(255)

--get current user
DECLARE @sys_usr char(30)
SET @sys_usr = SYSTEM_USER
SET @dbname = 'AdventureWorks'
CREATE table #tmpUsers(
spid int,  
ecid int,  
status varchar(50),                         
loginame varchar(50),                                                                                                                        
hostname varchar(50),                                                                                                                        
blk int,   
dbname varchar(50),                                                                                                                          
cmd varchar(50),             
request_id int)

INSERT INTO #tmpUsers EXEC SP_WHO
--cursor excluding current user
DECLARE LoginCursor CURSOR READ_ONLY
FOR SELECT spid, dbname FROM #tmpUsers WHERE dbname = @dbname 
DECLARE @spid varchar(10)
DECLARE @dbname2 varchar(40)
OPEN LoginCursor
FETCH NEXT FROM LoginCursor INTO @spid, @dbname2
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
	PRINT 'Killing ' + @spid
	SET @strSQL = 'KILL ' + @spid
	EXEC (@strSQL)
	END
	FETCH NEXT FROM LoginCursor INTO  @spid, @dbname2
END
CLOSE LoginCursor
DEALLOCATE LoginCursor
DROP table #tmpUsers
--kill users end




ALTER DATABASE [AdventureWorks] MODIFY NAME = [AdventureWorks_XX]
ALTER DATABASE [AdventureWorks_PUB] MODIFY NAME = [AdventureWorks]
ALTER DATABASE [AdventureWorks_XX] MODIFY NAME = [AdventureWorks_PUB]