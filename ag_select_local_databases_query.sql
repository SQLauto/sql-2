
SELECT 
	  [database_name]
  FROM [master].[dbo].[vw_AlwaysOn_health2]
  where is_ag_replica_local = 'LOCAL'
  and ag_replica_server = @@servername