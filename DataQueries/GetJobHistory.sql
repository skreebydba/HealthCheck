
-- job history 

DROP TABLE IF EXISTS #jobresults;

CREATE TABLE #jobresults
(server_name SYSNAME
,job_name SYSNAME
,job_id UNIQUEIDENTIFIER
,run_status VARCHAR(30)
,run_date DATE
,run_time CHAR(5)
,run_duration CHAR(8)
,sql_message_id INT
,sql_severity INT
,[message] NVARCHAR(4000));

use msdb

INSERT INTO #jobresults
(server_name
,job_name
,job_id 
,run_status
,run_date
,run_time
,run_duration
,sql_message_id
,sql_severity
,[message])
select 
  @@ServerName [server] 
, j.name [job_name]
,j.job_id
, case jh.run_status
    when 0 then 'Failed'
    when 1 then 'Succeeded'
    when 2 then 'Retry'
    when 3 then 'Cancelled'
    else 'Ooops!'
  end 'run_status'
, substring(convert(char(8),jh.run_date),1,4) 
  + '-' 
  + substring(convert(char(8),jh.run_date),5,2) 
  + '-' 
  + substring(convert(char(8),jh.run_date),7,2) [run_date] 
, CONCAT(RIGHT('0' + RTRIM(jh.run_time/10000), 2),':',RIGHT('0' + RTRIM(jh.run_time/100%100), 2)) AS  run_time
, CONCAT(RIGHT('0' + RTRIM(jh.run_duration/10000), 2), ':', RIGHT('0' + RTRIM(jh.run_duration/100%100), 2), ':', RIGHT('0' + RTRIM(jh.run_duration%100), 2)) AS [run_duration]
,jh.sql_message_id
,jh.sql_severity
,jh.message
from sysjobhistory jh inner join sysjobs j
on jh.job_id = j.job_id
where
--j.name in ( 'DUDTRACE - Gather Data' )
jh.step_id = 0 
order by 
  j.name
, jh.run_date desc
go

INSERT INTO Concurrency.hlthchk.JobHistory
([ServerName], 
[JobName], 
[JobId], 
[RunStatus], 
[RunDate], 
[RunTime], 
[RunDuration], 
[SqlMessageId], 
[SqlSeverity], 
[Message])
SELECT server_name,
job_name,
job_id,
run_status,
run_date,
run_time,
run_duration,
sql_message_id,
sql_severity,
[message]
FROM #jobresults;
--SELECT j.job_name, jh.step_id, jh.step_name, j.run_status, j.run_date, j.run_time, j.run_duration, jh.sql_severity, jh.[message] 
--FROM #jobresults j
--INNER JOIN sysjobhistory jh
--ON jh.job_id = j.job_id
--WHERE j.run_status = 'Failed'
--ORDER BY j.job_name, j.run_date, j.run_time, jh.step_id;
--RIGHT('0' + RTRIM((estimated_completion_time/1000)%60), 2)