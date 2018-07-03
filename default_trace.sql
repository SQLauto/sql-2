--sp_who2

--dbcc inputbuffer (58)
--dbcc inputbuffer (61)

--SELECT* FROM sys.configurations WHERE configuration_id = 1568

--SELECT  TE.name AS [EventName] ,
--        T.DatabaseName ,
--        t.DatabaseID ,
--        t.NTDomainName ,
--        t.ApplicationName ,
--        t.LoginName ,
--        t.SPID ,
--        t.StartTime ,
--        t.TextData ,
--        t.Severity ,
--        t.Error
--FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
--                                                              f.[value]
--                                                      FROM    sys.fn_trace_getinfo(NULL) f
--                                                      WHERE   f.property = 2
--                                                    )), DEFAULT) T
--        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
--WHERE   te.name = 'ErrorLog'


--SELECT  TE.name AS [EventName] ,
--        v.subclass_name ,
--        T.DatabaseName ,
--        t.DatabaseID ,
--        t.NTDomainName ,
--        t.ApplicationName ,
--        t.LoginName ,
--        t.SPID ,
--        t.StartTime ,
--        t.RoleName ,
--        t.TargetUserName ,
--        t.TargetLoginName ,
--        t.SessionLoginName
--FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
--                                                              f.[value]
--                                                      FROM    sys.fn_trace_getinfo(NULL) f
--                                                      WHERE   f.property = 2
--                                                    )), DEFAULT) T
--        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
--        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
--                                            AND v.subclass_value = t.EventSubClass
--WHERE   te.name IN ( 'Audit Addlogin Event', 'Audit Add DB User Event',
--                     'Audit Add Member to DB Role Event' )
--        AND v.subclass_name IN ( 'add', 'Grant database access' )

--database events
--SELECT  TE.name AS [EventName] ,
--        T.DatabaseName ,
--        t.DatabaseID ,
--        t.NTDomainName ,
--        t.ApplicationName ,
--        t.LoginName ,
--        t.SPID ,
--        t.Duration ,
--        t.StartTime ,
--        t.EndTime
--FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
--                                                              f.[value]
--                                                      FROM    sys.fn_trace_getinfo(NULL) f
--                                                      WHERE   f.property = 2
--                                                    )), DEFAULT) T
--        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
--WHERE   te.name = 'Data File Auto Grow'
--        OR te.name = 'Data File Auto Shrink'
--ORDER BY t.StartTime ;

--trace events captured
--DECLARE @TraceID INT;

--SELECT @TraceID = id FROM sys.traces WHERE is_default = 1;

--SELECT t.EventID, e.name as Event_Description
--  FROM sys.fn_trace_geteventinfo(@TraceID) t
--  JOIN sys.trace_events e ON t.eventID = e.trace_event_id
--  GROUP BY t.EventID, e.name;

/*
18	Audit Server Starts And Stops
20	Audit Login Failed
22	ErrorLog
46	Object:Created
47	Object:Deleted
55	Hash Warning
69	Sort Warnings
79	Missing Column Statistics
80	Missing Join Predicate
81	Server Memory Change
92	Data File Auto Grow
93	Log File Auto Grow
94	Data File Auto Shrink
95	Log File Auto Shrink
102	Audit Database Scope GDR Event
103	Audit Schema Object GDR Event
104	Audit Addlogin Event
105	Audit Login GDR Event
106	Audit Login Change Property Event
108	Audit Add Login to Server Role Event
109	Audit Add DB User Event
110	Audit Add Member to DB Role Event
111	Audit Add Role Event
115	Audit Backup/Restore Event
116	Audit DBCC Event
117	Audit Change Audit Event
152	Audit Change Database Owner
153	Audit Schema Object Take Ownership Event
155	FT:Crawl Started
156	FT:Crawl Stopped
164	Object:Altered
167	Database Mirroring State Change
175	Audit Server Alter Trace Event
218	Plan Guide Unsuccessful
*/