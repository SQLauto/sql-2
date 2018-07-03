DECLARE @RegKey NVARCHAR(255), @RegKey2 NVARCHAR(255), @RegKey3 NVARCHAR(255), @ListeningOnPort VARCHAR(10), @IP VARCHAR(15)
DECLARE @SERVER NVARCHAR(12), @GROUP NVARCHAR(12), @NODE NVARCHAR(12), @PNODE NVARCHAR(12), @STATUS NVARCHAR(17)
DECLARE @CMD VARCHAR(255), @CLUSTER NVARCHAR(13), @LEN INT, @ClusName VARCHAR(16), @ClusIP VARCHAR(15)

IF LEN(CAST( SERVERPROPERTY( 'InstanceName' ) AS nvarchar(128))) > 0
	BEGIN
	SET @RegKey = N'Software\Microsoft\Microsoft SQL Server\' + CAST( SERVERPROPERTY( 'InstanceName' ) AS nvarchar(128)) + N'\MSSQLServer\SuperSocketNetLib\Tcp'
	SET @RegKey2 = N'Cluster'
	SET @RegKey3 = N'Software\Microsoft\Microsoft SQL Server\' + CAST( SERVERPROPERTY( 'InstanceName' ) AS nvarchar(128)) + N'\Cluster'
	EXEC master..xp_regread N'HKEY_LOCAL_MACHINE' , @RegKey2 , N'ClusterName' , @ClusName OUT
	IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE name LIKE '#TempIP%')
	DROP TABLE #TempIP
	CREATE TABLE #TempIP(RegKey VARCHAR(255), IPVal VARCHAR(15), Data VARCHAR(10))
	INSERT #TempIP EXEC master..xp_regread N'HKEY_LOCAL_MACHINE' , @RegKey3 , N'ClusterIpAddr'
	SELECT @IP = IPVal FROM #TempIP
	DROP TABLE #TempIP
	END
ELSE	BEGIN
	SET @RegKey = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp'
	IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE name LIKE '#blat%')
	DROP TABLE #blat
	CREATE TABLE #blat(Line VARCHAR(255))
	INSERT #blat EXEC master..xp_cmdshell 'ipconfig'
	DELETE #blat WHERE CHARINDEX('IP Address', Line)<=0
	DELETE #blat WHERE Line IS NULL
	SELECT TOP 1 @IP = LTRIM((SUBSTRING(Line, CHARINDEX(':', Line)+1, 255))) FROM #blat
	DROP TABLE #blat
	END
EXEC master..xp_regread N'HKEY_LOCAL_MACHINE' , @RegKey , N'TcpPort' , @ListeningOnPort OUT

IF CONVERT(VARCHAR(30),@@SERVERNAME) LIKE '%\%'
	BEGIN
	IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE name LIKE '#output%')
	DROP TABLE #output
	CREATE TABLE #output (ID INT IDENTITY(1,1), OUTPUT NVARCHAR(255))
	SET @SERVER=LEFT((SELECT @@SERVERNAME),12)
	SET @CMD= 'cluster /CLUSTER:' + @ClusName + ' GROUP "' + @SERVER +'"'
	INSERT #output EXEC master..xp_cmdshell @CMD
	SELECT @NODE = RIGHT(LEFT(OUTPUT,33),12) FROM #output WHERE ID =5
	SELECT @LEN = LEN(OUTPUT) FROM #output WHERE ID = 5
	SELECT @STATUS = CASE 
 		WHEN @LEN = 44 THEN LEFT(RIGHT(OUTPUT,7),6)
 		WHEN @LEN = 45 THEN RIGHT(OUTPUT,8)
 		WHEN @LEN = 54 THEN Ltrim(RIGHT(OUTPUT,17))
 		END
	FROM #output WHERE ID = 5
	DROP TABLE #output
	IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE name LIKE '#prefnodes%')
	DROP TABLE #prefnodes
	CREATE TABLE #prefnodes (ID INT IDENTITY(1,1), OUTPUT NVARCHAR(255))
	SET @SERVER=LEFT((SELECT @@SERVERNAME),12)
	SET @CMD= 'cluster /CLUSTER:' + @ClusName + ' GROUP "' + @SERVER +'" /ListOwners'
	INSERT #prefnodes EXEC master..xp_cmdshell @CMD
	SELECT @PNODE = OUTPUT FROM #prefnodes WHERE ID = 6
	DROP TABLE #prefnodes
	SELECT @@SERVERNAME 'Virtual_Server', @ClusName 'Cluster', @PNODE 'Preferred_Node', @NODE 'Current_Node', @IP 'Server IP', @ListeningOnPort 'Port', @STATUS 'Status', GetDate() 'Date'
	END
ELSE
	SELECT @@SERVERNAME 'Server', @IP 'Server IP', @ListeningOnPort 'Port', GetDate() 'Date'