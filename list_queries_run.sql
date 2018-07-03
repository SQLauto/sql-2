--version 1
SELECT deqs.last_execution_time AS [Time], dest.text AS [Query]
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
ORDER BY deqs.last_execution_time DESC



--version 2
SELECT deqs.last_execution_time AS [Time],
SUBSTRING(dest.TEXT,(deqs.statement_start_offset/2)+1,
(
	(
		CASE deqs.statement_end_offset WHEN -1 
		THEN
			DATALENGTH(dest.TEXT)
		ELSE
			deqs.statement_end_offset
		END - deqs.statement_start_offset)/2
    ) + 1
) AS statement_text

FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
ORDER BY deqs.last_execution_time DESC


/* work in progress
SELECT deqs.last_request_start_time AS [TimeStart], deqs.last_request_end_time as TimeEnd, deqs.[host_name] as HostName, deqs.login_name as LoginName 
FROM sys.dm_exec_sessions AS deqs
--CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
ORDER BY deqs.total_elapsed_time DESC
*/