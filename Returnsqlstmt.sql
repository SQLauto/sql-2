SELECT  D.text SQLStatement, A.Session_ID SPID, 
ISNULL(B.status,A.status) Status, A.login_name Login, A.host_name 
HostName, C.BlkBy,  
DB_NAME(B.Database_ID) DBName, B.command, ISNULL(B.cpu_time, 
A.cpu_time) CPUTime, ISNULL((B.reads + B.writes),(A.reads + A.writes)) 
DiskIO, 
 A.last_request_start_time LastBatch, A.program_name FROM    
sys.dm_exec_sessions A    
LEFT JOIN    sys.dm_exec_requests B    ON A.session_id = B.session_id  
 LEFT JOIN       
(        SELECT                 A.request_session_id SPID,             
   B.blocking_session_id BlkBy           FROM sys.dm_tran_locks as A   
         
 INNER JOIN sys.dm_os_waiting_tasks as B            ON 
A.lock_owner_address = B.resource_address        ) C    ON 
A.Session_ID = C.SPID  
 OUTER APPLY sys.dm_exec_sql_text(sql_handle) D