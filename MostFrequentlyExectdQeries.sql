SELECT text, total_worker_time/execution_count AS [Avg CPU Time], execution_count
FROM sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY execution_count DESC