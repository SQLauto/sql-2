select distinct j.Name as "Job Name",j.enabled, j.category_id, j.description as "Job Description", h.run_date as LastStatusDate, case h.run_status 
when 0 then 'Failed' 
when 1 then 'Successful' 
when 3 then 'Cancelled' 
when 4 then 'In Progress' 
end as JobStatus
from sysJobHistory h, sysJobs j
where j.job_id = h.job_id and h.run_date = 
(select max(hi.run_date) from sysJobHistory hi where h.job_id = hi.job_id)
order by j.Name

