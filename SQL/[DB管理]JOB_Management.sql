
select *--distinct step_name
from [msdb].[dbo].[sysjobhistory]
where step_name='FcFtp_D_JOB'
order by run_date desc,run_time desc

select *--distinct step_name
from [msdb].[dbo].[sysjobhistory]
where step_name='SQL_TD002  存放主檔外其他資料源轉檔'
order by run_date desc,run_time desc


EXEC msdb.dbo.sp_help_jobhistory 
    @job_name = N'FTP_TD002'

