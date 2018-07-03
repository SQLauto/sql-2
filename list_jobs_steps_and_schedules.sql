SELECT 
	j.name as 'Job name', 
	jst.step_name as 'step name',
	jsch.job_id as 'job id from sysjobschedules' ,
	jss.name as 'job schedule name'
FROM
   dbo.sysjobs j 
   
   JOIN dbo.sysjobschedules js 
	ON j.job_id  = js.job_id
   JOIN dbo.sysjobsteps jst  
    ON j.job_id  = jst.job_id 
   JOIN  dbo.sysjobschedules jsch 
    ON jsch.job_id = j.job_id 
   JOIN [dbo].[sysschedules] jss 
    ON  jss.schedule_id = jsch.schedule_id
GO
    
--WHERE                                     --AND s.enabled = 1