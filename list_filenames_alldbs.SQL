SELECT DB_NAME(database_id) AS DatabaseName, name AS LogicalFileName, physical_name AS PhysicalFileName 
FROM sys.master_files AS mf