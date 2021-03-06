SELECT 
db_name(database_id) as 'database',
physical_name AS current_file_location,
name 
FROM sys.master_files
where left(physical_name, 1) = 'G'
order by 1,2,3