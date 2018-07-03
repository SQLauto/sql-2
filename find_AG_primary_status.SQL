--declare @primary varchar(100)
--declare @servername1 varchar(100)
--declare @servername2 varchar(100)

--set @servername1 = @@SERVERNAME
--select @@SERVERNAME


--SET @primary = (

SELECT distinct   
      ag_replica_role = 
            CASE 
                  WHEN ar_state.role_desc IS NULL THEN N'DISCONNECTED'
                  ELSE ar_state.role_desc 
            END	
FROM 
((
      sys.availability_groups AS ag 
      JOIN sys.availability_replicas AS ar 
      ON ag.group_id = ar.group_id
) 
JOIN sys.dm_hadr_availability_replica_states AS ar_state 
ON  ar.replica_id = ar_state.replica_id)
JOIN sys.dm_hadr_database_replica_states dr_state on
ag.group_id = dr_state.group_id and dr_state.replica_id = ar_state.replica_id
WHERE ar.replica_server_name = @@SERVERNAME

--)
--select @primary