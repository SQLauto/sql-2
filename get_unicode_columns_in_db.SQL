/*
Shan,
As discussed, I followed up with Microsoft on this.   SQL Server databases can handle both Unicode and non-Unicode data (even within the same table).   Running stored procedure sp_helpsort indicates the collation for Unicode Data in the SIEBELDB database. 
Results:
Latin1-General, case-insensitive, accent-sensitive, kanatype-insensitive, width-insensitive for Unicode Data, SQL Server Sort Order 52 on Code Page 1252 for non-Unicode Data

Here is a query to get all the database objects (tables & views) that have any Unicode data:
*/

select distinct s.name + '.'+ ao.name as db_object, ao.type_desc 
from sys.all_columns ac 
     join sys.all_objects ao on ac.object_id = ao.object_id
     join sys.schemas s on s.schema_id = ao.schema_id
where ac.collation_name = 'Latin1_General_CI_AS_KS_WS' -- Columns with Unicode Data
order by ao.type_desc 

/*
The results (attached) show that only the system tables have Unicode data, so the SIEBEL database can be considered as non-Unicode because all the USER Tables that the application will access are non-Unicode. 
Thanks,
Robert
*/

