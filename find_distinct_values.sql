DECLARE @table sysname
DECLARE @column sysname
DECLARE @datatype sysname
DECLARE @designed_length int
DECLARE @all_count int
DECLARE @sql nvarchar(4000)

SET NOCOUNT ON 
EXEC sp_updatestats

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- Will speed things up a bit

CREATE TABLE #table_info 
(table_name sysname NOT NULL
,column_name sysname NOT NULL
,data_type sysname NOT NULL
,designed_length int NULL
,max_length int NULL
,distinct_count int NULL
,all_count int NOT NULL
,cardinality AS 
CASE 
WHEN distinct_count IS NULL THEN CAST(data_type AS varchar(7))
WHEN all_count = 0 THEN CAST('No rows' AS varchar(7))
ELSE CAST(
CAST(CAST(distinct_count AS decimal)/CAST(all_count AS decimal) AS decimal(18,4)) AS varchar(7))
END
)

DECLARE c CURSOR FAST_FORWARD FOR 
SELECT 
isc.table_name, 
isc.column_name, 
isc.data_type, 
COALESCE(isc.character_maximum_length, isc.numeric_precision),
si.rowcnt
FROM information_schema.columns isc
INNER JOIN information_schema.tables ist
ON isc.table_name = ist.table_name
INNER JOIN sysindexes si
ON isc.table_name = OBJECT_NAME(si.id)
WHERE ist.table_type = 'base table'
AND ist.table_name not like 'dt%'
AND si.indid IN (0,1)
ORDER BY isc.table_name, isc.column_name

OPEN c
FETCH NEXT FROM c INTO @table, @column, @datatype, @designed_length, @all_count
WHILE @@FETCH_STATUS = 0
BEGIN
IF @datatype IN ('text', 'ntext', 'image')
BEGIN
SET @sql = 'SELECT ''' + @table + ''', ''' + @column + ''', ''' + @datatype + ''''
SET @sql = @sql + ', ' + CAST(@designed_length AS varchar(10)) + ', MAX(DATALENGTH([' + @column + ']))'
SET @sql = @sql + ', NULL' + ', ' + CAST(@all_count AS varchar(10)) + ' FROM [' + @table + ']'
END
ELSE
BEGIN
SET @sql = 'SELECT ''' + @table + ''', ''' + @column + ''', ''' + @datatype + ''''
SET @sql = @sql + ', ' + CAST(@designed_length AS varchar(10)) + ', MAX(LEN(CAST([' + @column + '] AS VARCHAR(8000))))'
SET @sql = @sql + ', COUNT(DISTINCT [' + @column + '])'
SET @sql = @sql + ', ' + CAST(@all_count AS varchar(10)) + ' FROM [' + @table + ']'
END
PRINT @sql
INSERT INTO #table_info (table_name, column_name, data_type, designed_length, max_length, distinct_count, all_count)
EXEC(@sql)
FETCH NEXT FROM c INTO @table, @column, @datatype, @designed_length, @all_count
END
CLOSE c
DEALLOCATE c

SELECT table_name, column_name, data_type, designed_length, max_length, distinct_count, all_count, cardinality
FROM #table_info

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

DROP TABLE #table_info