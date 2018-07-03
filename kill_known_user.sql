SET NOCOUNT ON

-- BEGIN CALLOUT A
DECLARE @LoginName SYSNAME
DECLARE @DatabaseName SYSNAME
DECLARE @NumberOfTimesToLoop INT
DECLARE @TimeToCheckKillInSec INT

-- BEGIN COMMENT
-- Customize these variables as needed.
-- END COMMENT
SET @LoginName = 'CARNIVAL\_sql_executive'
SET @DatabaseName = 'TRACE_DATA'
SET @NumberOfTimesToLoop = 2
SET @TimeToCheckKillInSec = 3
-- END CALLOUT A

DECLARE @WaitTimeStr VARCHAR(8)
DECLARE @i INT
DECLARE @sCurrentSPIDToKill VARCHAR(32)
DECLARE @sSPID VARCHAR(32)
DECLARE @ServerVersion NVARCHAR(128)

SET @sSPID = CAST(@@SPID AS VARCHAR(32))

-- BEGIN CALLOUT B
IF OBJECT_ID('tempdb..#utbSPWHO2', 'TABLE') IS NOT NULL
  DROP TABLE #utbSPWHO2

CREATE TABLE #utbSPWHO2 (
  SPID INT,
  [Status] NVARCHAR(128),
  LoginName NVARCHAR(128),
  HostName NVARCHAR(128),
  BlockedBy NVARCHAR(32),
  DBName NVARCHAR(128),
  Command NVARCHAR(128),
  CPUTime NVARCHAR(64),
  DiskIO NVARCHAR(64),
  LastBatchRunTime NVARCHAR(64),
  ProgramName NVARCHAR(512),
  SPID2 INT,
  RequestID INT)

-- BEGIN COMMENT
-- The clustered index uses the current @@SPID to make
-- sure that the index name is unique.
-- END COMMENT
EXEC('CREATE CLUSTERED INDEX
CI_#utbSPWHO2_' + @sSPID + '
ON #utbSPWHO2 (LoginName, DBName, SPID)')
-- END CALLOUT B

-- BEGIN CALLOUT C
-- BEGIN COMMENT
-- Determine SQL Server version because sp_who2 is version sensitive.
-- RequestID is returned for SQL Server 2005 but not SQL Server 2000.
-- END COMMENT
SET @ServerVersion = CAST(SERVERPROPERTY('ProductVersion')
  AS NVARCHAR(128))

-- BEGIN COMMENT
-- Execute sp_who2 and insert the appropriate results into the table.
-- END COMMENT
IF @ServerVersion LIKE '8.%' OR @ServerVersion LIKE '7.%'
  INSERT INTO #utbSPWHO2 (SPID, [Status], LoginName,
    HostName, BlockedBy, DBName, Command, CPUTime,
    DiskIO, LastBatchRunTime, ProgramName, SPID2)
  EXEC sp_who2
ELSE
  INSERT INTO #utbSPWHO2 (SPID, [Status], LoginName,
    HostName, BlockedBy, DBName, Command, CPUTime,
    DiskIO, LastBatchRunTime, ProgramName, SPID2, RequestID)
  EXEC sp_who2
-- END CALLOUT C

IF NOT EXISTS(
  SELECT *
  FROM #utbSPWHO2
  WHERE LoginName = @LoginName
    AND DBName = @DatabaseName)
BEGIN
    PRINT('The user is not currently using the DB')
    RETURN
END

-- BEGIN COMMENT
-- @WaitTimeStr is used in a WAITFOR DELAY command later.
-- END COMMENT
SET @WaitTimeStr = '00:0' 
  + CAST(@TimeToCheckKillInSec/60 AS CHAR(1))
  + CASE WHEN (@TimeToCheckKillInSec%60) < 10
    THEN ':0'
    ELSE ':'
  END
  + CAST(@TimeToCheckKillInSec%60 AS VARCHAR(2))

-- BEGIN CALLOUT D
-- BEGIN COMMENT
-- Get the SPID of the first process to kill. Check HostName
-- to make sure an internal machine process won't be killed.
-- END COMMENT
SELECT @sCurrentSPIDToKill = CAST(MIN(SPID) AS VARCHAR(32))
FROM #utbSPWHO2
WHERE LoginName = @LoginName
  AND DBName = @DatabaseName
  AND RTRIM(LTRIM(HostName)) <> N'.'
  AND SPID <> @@SPID
-- END CALLOUT D

WHILE @sCurrentSPIDToKill IS NOT NULL

-- BEGIN CALLOUT E
BEGIN
-- BEGIN COMMENT
  -- Launch the KILL command.
-- END COMMENT
  EXEC('KILL ' + @sCurrentSPIDToKill)
-- END CALLOUT E

-- BEGIN CALLOUT F
-- BEGIN COMMENT
  -- Check to see whether the process was killed.
-- END COMMENT
  TRUNCATE TABLE #utbSPWHO2
  IF @ServerVersion LIKE '8.%' OR @ServerVersion LIKE '7.%'
    INSERT INTO #utbSPWHO2 (SPID, [Status], LoginName,
      HostName, BlockedBy, DBName, Command, CPUTime,
      DiskIO, LastBatchRunTime, ProgramName, SPID2)
    EXEC sp_who2 
  ELSE
    INSERT INTO #utbSPWHO2 (SPID, [Status], LoginName,
      HostName, BlockedBy, DBName, Command, CPUTime,
      DiskIO, LastBatchRunTime, ProgramName, SPID2, RequestID)
    EXEC sp_who2

  SET @i = 1

  WHILE EXISTS(
  SELECT *
  FROM #utbSPWHO2
  WHERE LoginName = @LoginName
    AND DBName = @DatabaseName
    AND SPID = CAST(@sCurrentSPIDToKill AS INT))

  AND @i <= @NumberOfTimesToLoop

  BEGIN
-- BEGIN COMMENT
    -- Wait, then check again to see whether the process was killed.
-- END COMMENT
    WAITFOR DELAY @WaitTimeStr
    TRUNCATE TABLE #utbSPWHO2
    IF @ServerVersion LIKE '8.%' OR @ServerVersion LIKE '7.%'
      INSERT INTO #utbSPWHO2 (SPID, [Status], LoginName,
        HostName, BlockedBy, DBName, Command, CPUTime,
        DiskIO, LastBatchRunTime, ProgramName, SPID2)
      EXEC sp_who2
    ELSE
      INSERT INTO #utbSPWHO2 (SPID, [Status], LoginName,
        HostName, BlockedBy, DBName, Command, CPUTime,
        DiskIO, LastBatchRunTime, ProgramName, SPID2, RequestID)
      EXEC sp_who2

    SET @i = @i + 1

  END

-- BEGIN COMMENT
  -- Check to see whether the loop exited because the process was
  -- killed or the loop threshold was reached.
-- END COMMENT
  IF @i > @NumberOfTimesToLoop
  BEGIN
-- BEGIN COMMENT
    -- If the loop threshold was reached, notify and abort.
-- END COMMENT
    RAISERROR('The script could not kill process id = %s.', 16, 1,
      @sCurrentSPIDToKill)
    RETURN
  END
-- END CALLOUT F
  ELSE
-- BEGIN CALLOUT G
    PRINT('Process id ' + @sCurrentSPIDToKill + ' was killed successfully')
-- BEGIN COMMENT
  -- Find the next process to kill.
-- END COMMENT
  SET @sCurrentSPIDToKill = NULL
  SELECT @sCurrentSPIDToKill = CAST(MIN(SPID) AS VARCHAR(32))
  FROM #utbSPWHO2
  WHERE LoginName = @LoginName
    AND DBName = @DatabaseName
    AND RTRIM(LTRIM(HostName)) <> N'.'
    AND SPID <> @@SPID
-- END CALLOUT G
END

