SELECT 

      ag.name AS ag_name, 

      ar.replica_server_name AS ag_replica_server,

                  db_name(dr_state.database_id) as database_name,

      is_ag_replica_local = 

                                                CASE

                                                                WHEN ar_state.is_local = 1 THEN N'LOCAL'

                                                                ELSE 'REMOTE'

                                                END         , 

      ag_replica_role = 

            CASE 

                  WHEN ar_state.role_desc IS NULL THEN N'DISCONNECTED'

                  ELSE ar_state.role_desc 

            END, 

                  ar.availability_mode_desc as availability_mode,

                  ar.failover_mode_desc as failover_mode,

      ag_replica_operational_state = 

            CASE 

                  WHEN ar_state.operational_state_desc IS NULL THEN N'NOT LOCAL'

                  ELSE ar_state.operational_state_desc 

            END, 

      ag_replica_connected_state = 

            CASE 

                  WHEN ar_state.connected_state_desc IS NULL THEN 

                        CASE 

                              WHEN ar_state.is_local = 1 THEN N'CONNECTED'

                              ELSE N'<unknown>'

                        END

                  ELSE ar_state.connected_state_desc 

            END,

                  dr_state.synchronization_state_desc as synchronization_state,

                  dr_state.is_suspended,

                  dr_state.suspend_reason_desc as suspend_reason, 

      ar.secondary_role_allow_connections_desc as secondary_allow_read,

                  dr_state.log_send_queue_size as log_send_queue,

                  dr_state.last_sent_time as last_sent,

                  dr_state.last_received_time as last_received,

                  dr_state.last_hardened_time as last_hardened,

                  dr_state.last_redone_time as last_redo,

                  dr_state.last_commit_time as last_commit

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


