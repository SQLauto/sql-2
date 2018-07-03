-- =============================================
-- Declare and using a READ_ONLY cursor
-- =============================================
set nocount on
DECLARE C1 CURSOR
READ_ONLY


FOR 

--select '[dbo].[' + name + ']' from sys.tables order by name
SELECT '[' + s.name + '].[' + t.name + ']'
FROM   sys.tables AS t 
INNER JOIN sys.schemas AS s 
ON t.[schema_id] = s.[schema_id] 
order by t.name

DECLARE @name varchar(200)
OPEN C1

FETCH NEXT FROM C1 INTO @name
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		DECLARE @message varchar(100)
		DECLARE @s varchar(1000)
		SELECT @message = '-- Table: ' + @name
		SELECT @message
		----
		SELECT referencing_entity_name 
		FROM sys.dm_sql_referencing_entities(@name,'OBJECT')
		--uncomment these for only procs
		--join sysobjects o on
		--o.name = referencing_entity_name	and
		--o.type = 'p'	
		-----
	END
	FETCH NEXT FROM C1 INTO @name
END

CLOSE C1
DEALLOCATE C1
GO

