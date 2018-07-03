--- Make sure we are on the correct db

USE [TD_Backup]
GO
--- Do not show record counts 

SET NOCOUNT ON

--- Declare variables to be use in script

DECLARE	@ObjectID	INT
,		@ObjectName VARCHAR(500)
,		@SQL		NVARCHAR(2000)
,		@Count		INT
,		@ObjectType	VARCHAR(1000)

--- Create temp table that is going to be used throughout the script

CREATE TABLE #ObjectTemp (ObjectID INT IDENTITY(1,1) NOT NULL, ObjectName VARCHAR(250), ObjectType VARCHAR(100))
SET @Count = 0 

--- First let's drop all the constraints on the tables
------ CAUTION:  Running this part removes all constraints from the database -------

INSERT INTO #ObjectTemp (ObjectName, ObjectType)
SELECT Table_Schema + '.' + Table_Name, Constraint_Name
FROM INFORMATION_SCHEMA.Table_CONSTRAINTS
ORDER BY constraint_type , Table_Name

SELECT @ObjectID = MIN(ObjectID) FROM #ObjectTemp

WHILE @ObjectID IS NOT NULL
BEGIN

SELECT	@ObjectName = ObjectName
,	@ObjectType = ObjectType
FROM #ObjectTemp WHERE ObjectID = @ObjectID

SET @SQL = 'ALTER TABLE ' + @ObjectName + ' DROP CONSTRAINT [' + @ObjectType + ']'

EXECUTE SP_EXECUTESQL @SQL

SELECT @ObjectID = MIN(ObjectID) FROM #ObjectTemp WHERE ObjectID > @ObjectID
SET @ObjectName = NULL
SET @SQL = NULL
SET @COUNT = @Count + 1

END
PRINT CAST(@Count AS VARCHAR(10)) + ' Constraint(s) deleted'



