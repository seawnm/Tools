
--查詢目前正在執行中之JOB
select 'YourServerName' ServerName,case when sja.start_execution_date is not null and sja.stop_execution_date is null then '執行中' else '' end 狀態
,job.name,job.description
,sja.run_requested_date,sja.start_execution_date
,sja.last_executed_step_id
,sja.stop_execution_date
,sja.next_scheduled_run_date
,sjt.step_name,sjt.subsystem,sjt.command,sjt.database_name
from YourServerName.msdb.dbo.sysjobactivity sja
left join YourServerName.msdb.dbo.sysjobs job on sja.job_id=job.job_id
left join YourServerName.msdb.dbo.sysjobsteps sjt
on sja.last_executed_step_id=sjt.step_id and job.job_id=sjt.job_id
where sja.session_id=(select max(session_id) from YourServerName.msdb.dbo.syssessions) 
order by 狀態 desc,start_execution_date desc

select 'YourServerName' ServerName,case when sja.start_execution_date is not null and sja.stop_execution_date is null then '執行中' else '' end 狀態
,job.name,job.description
,sja.run_requested_date,sja.start_execution_date
,sja.last_executed_step_id
,sja.stop_execution_date
,sja.next_scheduled_run_date
,sjt.step_name,sjt.subsystem,sjt.command,sjt.database_name
from YourServerName.msdb.dbo.sysjobactivity sja
left join YourServerName.msdb.dbo.sysjobs job on sja.job_id=job.job_id
left join YourServerName.msdb.dbo.sysjobsteps sjt
on sja.last_executed_step_id=sjt.step_id and job.job_id=sjt.job_id
where sja.session_id=(select max(session_id) from YourServerName.msdb.dbo.syssessions) 
order by 狀態 desc,start_execution_date desc

select 'YourServerName' ServerName,case when sja.start_execution_date is not null and sja.stop_execution_date is null then '執行中' else '' end 狀態
,job.name,job.description
,sja.run_requested_date,sja.start_execution_date
,sja.last_executed_step_id
,sja.stop_execution_date
,sja.next_scheduled_run_date
,sjt.step_name,sjt.subsystem,sjt.command,sjt.database_name
from YourServerName.msdb.dbo.sysjobactivity sja
left join YourServerName.msdb.dbo.sysjobs job on sja.job_id=job.job_id
left join YourServerName.msdb.dbo.sysjobsteps sjt
on sja.last_executed_step_id=sjt.step_id and job.job_id=sjt.job_id
where sja.session_id=(select max(session_id) from YourServerName.msdb.dbo.syssessions) 
order by 狀態 desc,start_execution_date desc

--select 'S8200FTPWDB01' ServerName,case when sja.start_execution_date is not null and sja.stop_execution_date is null then '執行中' else '' end 狀態
--,job.name,job.description
--,sja.run_requested_date,sja.start_execution_date
--,sja.last_executed_step_id
--,sja.stop_execution_date
--,sja.next_scheduled_run_date
--,sjt.step_name,sjt.subsystem,sjt.command,sjt.database_name
--from S8200FTPWDB01.msdb.dbo.sysjobactivity sja
--left join S8200FTPWDB01.msdb.dbo.sysjobs job on sja.job_id=job.job_id
--left join S8200FTPWDB01.msdb.dbo.sysjobsteps sjt
--on sja.last_executed_step_id=sjt.step_id and job.job_id=sjt.job_id
--where sja.session_id=(select max(session_id) from S8200FTPWDB01.msdb.dbo.syssessions) 
--order by 狀態 desc,start_execution_date desc

select 'YourServerName' ServerName,case when sja.start_execution_date is not null and sja.stop_execution_date is null then '執行中' else '' end 狀態
,job.name,job.description
,sja.run_requested_date,sja.start_execution_date
,sja.last_executed_step_id
,sja.stop_execution_date
,sja.next_scheduled_run_date
,sjt.step_name,sjt.subsystem,sjt.command,sjt.database_name
from YourServerName.msdb.dbo.sysjobactivity sja
left join YourServerName.msdb.dbo.sysjobs job on sja.job_id=job.job_id
left join YourServerName.msdb.dbo.sysjobsteps sjt
on sja.last_executed_step_id=sjt.step_id and job.job_id=sjt.job_id
where sja.session_id=(select max(session_id) from YourServerName.msdb.dbo.syssessions) 
order by 狀態 desc,start_execution_date desc

--查詢JOB歷史執行記錄(已完成才會填入)
select sjh.server
,CASE sjh.run_status
         WHEN 0 THEN 'Failed'
         WHEN 1 THEN 'Succeeded'
         WHEN 2 THEN 'Retry'
         WHEN 3 THEN 'Canceled'
         WHEN 5 THEN 'Unknown'
       END as run_status         
,sjh.run_date
, LEFT(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 2)
       + ':'
       + Substring(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 3, 2)
       + ':'
       + RIGHT(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 2)         AS runtime
,job.name,job.description
,sjt.step_id,sjt.step_name,sjt.subsystem,sjt.command,sjt.database_name
,sjh.message
,LEFT(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 2)
       + ':'
       + Substring(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 3, 2)
       + ':'
       + RIGHT(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 2) AS run_duration
from YourServerName.msdb.dbo.sysjobs job
join YourServerName.msdb.dbo.sysjobhistory sjh
on sjh.job_id=job.job_id
join YourServerName.msdb.dbo.sysjobsteps sjt
on sjh.step_id=sjt.step_id and job.job_id=sjt.job_id
--where job.name='OverSea_FTP_Run99'
order by sjh.run_date desc,sjh.run_time desc


select sjh.server
,CASE sjh.run_status
         WHEN 0 THEN 'Failed'
         WHEN 1 THEN 'Succeeded'
         WHEN 2 THEN 'Retry'
         WHEN 3 THEN 'Canceled'
         WHEN 5 THEN 'Unknown'
       END as run_status         
,sjh.run_date
, LEFT(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 2)
       + ':'
       + Substring(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 3, 2)
       + ':'
       + RIGHT(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 2)         AS runtime
,job.name,job.description
,sjt.step_id,sjt.step_name,sjt.subsystem,sjt.command,sjt.database_name
,sjh.message
,LEFT(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 2)
       + ':'
       + Substring(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 3, 2)
       + ':'
       + RIGHT(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 2) AS run_duration
from YourServerName.msdb.dbo.sysjobs job
join YourServerName.msdb.dbo.sysjobhistory sjh
on sjh.job_id=job.job_id
join YourServerName.msdb.dbo.sysjobsteps sjt
on sjh.step_id=sjt.step_id and job.job_id=sjt.job_id
--where job.name='OverSea_FTP_Run99'
order by sjh.run_date desc,sjh.run_time desc


select sjh.server
,CASE sjh.run_status
         WHEN 0 THEN 'Failed'
         WHEN 1 THEN 'Succeeded'
         WHEN 2 THEN 'Retry'
         WHEN 3 THEN 'Canceled'
         WHEN 5 THEN 'Unknown'
       END as run_status         
,sjh.run_date
, LEFT(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 2)
       + ':'
       + Substring(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 3, 2)
       + ':'
       + RIGHT(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 2)         AS runtime
,job.name,job.description
,sjt.step_id,sjt.step_name,sjt.subsystem,sjt.command,sjt.database_name
,sjh.message
,LEFT(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 2)
       + ':'
       + Substring(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 3, 2)
       + ':'
       + RIGHT(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 2) AS run_duration
from YourServerName.msdb.dbo.sysjobs job
join YourServerName.msdb.dbo.sysjobhistory sjh
on sjh.job_id=job.job_id
join YourServerName.msdb.dbo.sysjobsteps sjt
on sjh.step_id=sjt.step_id and job.job_id=sjt.job_id
--where job.name='OverSea_FTP_Run99'
order by sjh.run_date desc,sjh.run_time desc

select sjh.server
,CASE sjh.run_status
         WHEN 0 THEN 'Failed'
         WHEN 1 THEN 'Succeeded'
         WHEN 2 THEN 'Retry'
         WHEN 3 THEN 'Canceled'
         WHEN 5 THEN 'Unknown'
       END as run_status         
,sjh.run_date
, LEFT(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 2)
       + ':'
       + Substring(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 3, 2)
       + ':'
       + RIGHT(Replicate('0', 6 - Len(sjh.run_time)) + Cast(sjh.run_time AS VARCHAR(6)), 2)         AS runtime
,job.name,job.description
,sjt.step_id,sjt.step_name,sjt.subsystem,sjt.command,sjt.database_name
,sjh.message
,LEFT(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 2)
       + ':'
       + Substring(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 3, 2)
       + ':'
       + RIGHT(Replicate('0', 6 - Len(sjh.run_duration)) + Cast(sjh.run_duration AS VARCHAR(6)), 2) AS run_duration
from YourServerName.msdb.dbo.sysjobs job
join YourServerName.msdb.dbo.sysjobhistory sjh
on sjh.job_id=job.job_id
join YourServerName.msdb.dbo.sysjobsteps sjt
on sjh.step_id=sjt.step_id and job.job_id=sjt.job_id
--where job.name='OverSea_FTP_Run99'
order by sjh.run_date desc,sjh.run_time desc

/*
--查詢目前正在執行的工作
select * from sys.dm_exec_requests
select * from sys.dm_exec_sessions
*/


/*
--查詢所有JOB及下次執行時間
SELECT sb.enabled,
       sb.name                                                                                      AS job_name,
       sb.description                                                                               AS adescription,
       CASE next_run_date WHEN '0' THEN '0' ELSE Cast(LEFT(next_run_date, 4) AS CHAR(4)) + '/' + Cast(Substring(Cast(next_run_date AS CHAR(8)), 5, 2) AS CHAR(2)) + '/' + Cast(RIGHT(next_run_date, 2) AS CHAR(2)) END + ' '
       + LEFT(Replicate('0', 6 - Len(sc.next_run_time)) + Cast(sc.next_run_time AS VARCHAR(6)), 2)
       + ':'
       + Substring(Replicate('0', 6 - Len(sc.next_run_time)) + Cast(sc.next_run_time AS VARCHAR(6)), 3, 2)
       + ':'
       + RIGHT(Replicate('0', 6 - Len(sc.next_run_time)) + Cast(sc.next_run_time AS VARCHAR(6)), 2) AS next_run_time
--       ,sb.job_id
	   ,sb.date_created,date_modified
FROM   (select * from msdb.dbo.sysjobschedules where next_run_date in (select max(next_run_date) from msdb.dbo.sysjobschedules group by job_id)) AS sc
       RIGHT OUTER JOIN msdb.dbo.sysjobs AS sb
                    ON sc.job_id = sb.job_id 
where sb.name='[ALM_SQLMag]Record_DBSource'
order by job_name
*/