select distinct 
j.originating_server as 'Server Name'
,j.Name as 'Job Name'
,j.enabled as 'Enabled Job'
, j.description as 'Job Description'
, case isnull(CAST(h.run_date as varchar(20)) , '')
when '' then ''
when '0' then ''
else isnull(CAST(h.run_date as varchar(20)) , '')
END as 'Last Status Date'

, case h.run_status 
when 0 then 'Failed' 
when 1 then 'Successful' 
when 3 then 'Cancelled' 
when 4 then 'In Progress'
else '' 
end as 'Job Status'

, s.enabled as 'Enabled Schedule'

, case s.freq_type
when 1 Then 'Once'
when 4 Then 'Daily'
when 8 Then 'Weekly'
when 16 Then 'Monthly'
when 32 Then 'Monthly, relative to the freq_ interval'
when 64 Then 'Run when SQLServerAgent service starts.'
END as 'Frequency'

, case cast(s.freq_subday_interval as varchar(10)) 
when '0' then ''
else cast(s.freq_subday_interval as varchar(10)) 
END as 'Every' 

, CASE s.freq_subday_type
when 0x1 then 'At the specified time '
when 0x4 then 'Minutes '
when 0x8 then 'Hours '
END as 'Times'


--from dba.dbo.VW_MSDB_JOBS j
from MSDB.dbo.sysjobs j
--left join dba.dbo.VW_MSDB_JOB_SCHEDULES s on
left join MSDB.dbo.sysjobschedules s on
	j.job_id = s.job_id
--left join dba.dbo.VW_MSDB_JOB_HISTORY h on
left join MSDB.dbo.sysjobhistory h on  
	j.job_id = h.job_id 
	and h.run_date = 
	(
		select max(hi.run_date) 
		--from dba.dbo.VW_MSDB_JOB_HISTORY hi 
		from MSDB.dbo.sysjobhistory hi
		where h.job_id = hi.job_id
	)


--added 5/15/2006 to get those that failed on the day only
	and h.run_date = 
	(
		select cast(rtrim(str(year(getdate()))) + 
		case len(month(getdate()))
		when 1 then '0' + rtrim(ltrim(str(month(getdate()))))
		when 2 then '' + rtrim(ltrim(str(month(getdate()))))
		end + 
		case len(day(getdate()))
		when 1 then '0' + rtrim(ltrim(str(day(getdate()))))
		when 2 then '' + rtrim(ltrim(str(day(getdate()))))
		end 
		as int)
	)


where h.run_status = 0

order by 1,2