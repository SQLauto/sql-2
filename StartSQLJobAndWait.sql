--2012-04-02 19:57:05
/*
--=============================================
--Author: TVdP
--Create date: 20090706
--Description: Starts a SQLAgent Job and waits for it to finish or until a specified wait period elapsed
--@result: 1 -> OK
--0 -> still running after maxwaitmins
--Changes: John Morales 4/2/2012 --Updated script so that it doesn't depend on whether the job starts in the first second.
--=============================================
*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StartAgentJobAndWait]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[StartAgentJobAndWait]
GO

CREATE procedure [dbo].[StartAgentJobAndWait](@job nvarchar(128), @maxwaitmins int = 5 ) --@result int output
as begin

set NOCOUNT ON;
set XACT_ABORT ON;

BEGIN TRY

declare @running as int
declare @seccount as int
declare @maxseccount as int
declare @start_job as bigint
declare @run_status as int
declare @last_run_date as int
declare @last_run_time as int

set @start_job = cast(convert(varchar, getdate(), 112) as bigint) * 1000000 + datepart(hour, getdate()) * 10000 + datepart(minute, getdate()) * 100 + datepart(second, getdate())

set @maxseccount = 60*@maxwaitmins
set @seccount = 0
set @running = 0

declare @job_owner sysname
declare @job_id UNIQUEIDENTIFIER

set @job_owner = SUSER_SNAME()

--get job id
select @job_id=job_id
from msdb.dbo.sysjobs sj
where sj.name=@job

--invalid job name then exit with an error
if @job_id is null
RAISERROR (N'Unknown job: %s.', 16, 1, @job)

--output from stored procedure xp_sqlagent_enum_jobs is captured in the following table
declare @xp_results TABLE ( job_id UNIQUEIDENTIFIER NOT NULL,
last_run_date INT NOT NULL,
last_run_time INT NOT NULL,
next_run_date INT NOT NULL,
next_run_time INT NOT NULL,
next_run_schedule_id INT NOT NULL,
requested_to_run INT NOT NULL, -- BOOL
request_source INT NOT NULL,
request_source_id sysname COLLATE database_default NULL,
running INT NOT NULL, --BOOL
current_step INT NOT NULL,
current_retry_attempt INT NOT NULL,
job_state INT NOT NULL)
--check job run state
insert into @xp_results
execute master.dbo.xp_sqlagent_enum_jobs 1, @job_owner, @job_id

select @last_run_date = ISNULL(last_run_date, 0), @last_run_time = ISNULL(last_run_time, 0) from @xp_results

--start the job
declare @r as int
exec @r = msdb..sp_start_job @job

--quit if unable to start
if @r <>0
RAISERROR (N'Could not start job: %s.', 16, 2, @job)

WHILE NOT EXISTS (SELECT 1 FROM @xp_results where last_run_date > @last_run_date or last_run_time > @last_run_time) AND @seccount < @maxseccount
BEGIN
RAISERROR('Waiting for %s to finish, time elasped %d sec', 0, 1, @job, @seccount) WITH NOWAIT;
WAITFOR DELAY '0:0:01';
set @seccount = @seccount + 1
insert into @xp_results
execute master.dbo.xp_sqlagent_enum_jobs 1, @job_owner, @job_id
END

set @running = (SELECT top 1 running from @xp_results)

--result: not ok (=1) if still running

if @running = 1 begin
--still running
return 1
end
else begin

--did it finish ok ?
set @run_status = 0

select @run_status=run_status
from msdb.dbo.sysjobhistory
where job_id=@job_id
and cast(run_date as bigint) * 1000000 + run_time >= @start_job

if @run_status=1
return 0 --finished ok
else --error
RAISERROR (N'Job %s did not finish successfully.', 16, 2, @job)

end

END TRY
BEGIN CATCH

DECLARE
@ErrorMessage NVARCHAR(4000),
@ErrorNumber INT,
@ErrorSeverity INT,
@ErrorState INT,
@ErrorLine INT,
@ErrorProcedure NVARCHAR(200);

SELECT
@ErrorNumber = ERROR_NUMBER(),
@ErrorSeverity = ERROR_SEVERITY(),
@ErrorState = ERROR_STATE(),
@ErrorLine = ERROR_LINE(),
@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

SELECT @ErrorMessage =
N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +
'Message: ' + ERROR_MESSAGE();

RAISERROR
(
@ErrorMessage,
@ErrorSeverity,
1,
@ErrorNumber, -- original error number.
@ErrorSeverity, -- original error severity.
@ErrorState, -- original error state.
@ErrorProcedure, -- original error procedure name.
@ErrorLine -- original error line number.
);

END CATCH

end
