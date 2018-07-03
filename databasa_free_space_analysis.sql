BEGIN

SET NOCOUNT ON

IF EXISTS (SELECT 1 FROM Tempdb..Sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#DBFileInfo'))
BEGIN
DROP TABLE #DBFileInfo
END


IF EXISTS (SELECT 1 FROM Tempdb..Sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#LogSizeStats'))
BEGIN
DROP TABLE #LogSizeStats
END

IF EXISTS (SELECT 1 FROM Tempdb..Sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#DataFileStats'))
BEGIN
DROP TABLE #DataFileStats
END

IF EXISTS (SELECT 1 FROM Tempdb..Sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#FixedDrives'))
BEGIN
DROP TABLE #FixedDrives
END

CREATE TABLE #FixedDrives 
(DriveLetter VARCHAR(10), 
MB_Free DEC(20,2))


CREATE TABLE #DataFileStats 
(DBName VARCHAR(255), 
DBId INT,
FileId TINYINT, 
[FileGroup] TINYINT, 
TotalExtents DEC(20,2),
UsedExtents DEC(20,2),
[Name] VARCHAR(255), 
[FileName] VARCHAR(400))


CREATE TABLE #LogSizeStats 
(DBName VARCHAR(255) NOT NULL PRIMARY KEY CLUSTERED,
DBId INT,
LogFile REAL, 
LogFileUsed REAL,
Status BIT) 

CREATE TABLE #DBFileInfo
([ServerName] VARCHAR(255),
[DBName] VARCHAR(65),
[LogicalFileName] VARCHAR(400),
[UsageType] VARCHAR (30),
[Size_MB] DEC(20,2), 
[SpaceUsed_MB] DEC(20,2),
[MaxSize_MB] DEC(20,2),
[NextAllocation_MB] DEC(20,2), 
[GrowthType] VARCHAR(65),
[FileId] SMALLINT,
[GroupId] SMALLINT,
[PhysicalFileName] VARCHAR(400),
[DateChecked] DATETIME) 


DECLARE @SQLString VARCHAR(3000)
DECLARE @MinId INT
DECLARE @MaxId INT
DECLARE @DBName VARCHAR(255)

DECLARE @tblDBName TABLE
(RowId INT IDENTITY(1,1),
DBName VARCHAR(255),
DBId INT)

INSERT INTO @tblDBName (DBName,DBId)
SELECT [Name],DBId FROM Master..sysdatabases WHERE [name] = 'OASIS_Hist'
--(Status & 512) = 0 /*NOT IN (536,528,540,2584,1536,512,4194841)*/ ORDER BY [Name]


INSERT INTO #LogSizeStats (DBName,LogFile,LogFileUsed,Status)
EXEC ('DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS')

UPDATE #LogSizeStats 
SET DBId = DB_ID(DBName)

INSERT INTO #FixedDrives EXEC Master..XP_FixedDrives


SELECT @MinId = MIN(RowId),
@MaxId = MAX(RowId)
FROM @tblDBName

WHILE (@MinId <= @MaxId)
BEGIN
SELECT @DBName = [DBName]
FROM @tblDBName
WHERE RowId = @MinId

SELECT @SQLString =
'SELECT ServerName = @@SERVERNAME,'+
' DBName = '''+@DBName+''','+
' LogicalFileName = [name],'+
' UsageType = CASE WHEN (64&[status])=64 THEN ''Log'' ELSE ''Data'' END,'+
' Size_MB = [size]*8/1024.00,'+
' SpaceUsed_MB = NULL,'+
' MaxSize_MB = CASE [maxsize] WHEN -1 THEN -1 WHEN 0 THEN [size]*8/1024.00 ELSE maxsize*8/1024.00 END,'+
' NextExtent_MB = CASE WHEN (1048576&[status])=1048576 THEN ([growth]/100.00)*([size]*8/1024.00) WHEN [growth]=0 THEN 0 ELSE [growth]*8/1024.00 END,'+
' GrowthType = CASE WHEN (1048576&[status])=1048576 THEN ''%'' ELSE ''Pages'' END,'+
' FileId = [fileid],'+
' GroupId = [groupid],'+
' PhysicalFileName= [filename],'+
' CurTimeStamp = GETDATE()'+
'FROM '+@DBName+'..sysfiles' 

PRINT @SQLString
INSERT INTO #DBFileInfo
EXEC (@SQLString)

UPDATE #DBFileInfo
SET SpaceUsed_MB = (SELECT LogFileUsed FROM #LogSizeStats WHERE DBName = @DBName)
WHERE UsageType = 'Log'
AND DBName = @DBName 


SELECT @SQLString = 'USE ' + @DBName + ' DBCC SHOWFILESTATS WITH NO_INFOMSGS'

INSERT #DataFileStats (FileId,[FileGroup],TotalExtents,UsedExtents,[Name],[FileName])
EXECUTE(@SQLString)

UPDATE #DBFileInfo
SET [SpaceUsed_MB] = S.[UsedExtents]*64/1024.00
FROM #DBFileInfo AS F
INNER JOIN #DataFileStats AS S
ON F.[FileId] = S.[FileId]
AND F.[GroupId] = S.[FileGroup]
AND F.[DBName] = @DBName

TRUNCATE TABLE #DataFileStats


SELECT @MinId = @MInId + 1
END

SELECT [ServerName],
[DBName],
[LogicalFileName],
[UsageType] AS SegmentName,
B.MB_Free AS FreeSpaceInDrive,
[Size_MB],
[SpaceUsed_MB],
[MaxSize_MB],
[NextAllocation_MB],
CASE MaxSize_MB WHEN -1 THEN CAST(CAST(([NextAllocation_MB]/[Size_MB])*100 AS INT) AS VARCHAR(10))+' %' ELSE 'Pages' END AS [GrowthType],
[FileId],
[GroupId],
[PhysicalFileName],
[DateChecked]
FROM #DBFileInfo AS A
LEFT JOIN #FixedDrives AS B
ON SUBSTRING(A.PhysicalFileName,1,1) = B.DriveLetter
ORDER BY DBName,GroupId,FileId

IF EXISTS (SELECT 1 FROM Tempdb..Sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#DBFileInfo'))
BEGIN
DROP TABLE #DBFileInfo
END


IF EXISTS (SELECT 1 FROM Tempdb..Sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#LogSizeStats'))
BEGIN
DROP TABLE #LogSizeStats
END

IF EXISTS (SELECT 1 FROM Tempdb..Sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#DataFileStats'))
BEGIN
DROP TABLE #DataFileStats
END

IF EXISTS (SELECT 1 FROM Tempdb..Sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#FixedDrives'))
BEGIN
DROP TABLE #FixedDrives
END

END

GO
