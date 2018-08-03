GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--ALTER PROCEDURE [dbo].[sp_Record_DBSource] AS

--查詢線上執行的session
if object_id('tempdb..#sp_who2') is not null
	drop table #sp_who2
CREATE TABLE #sp_who2 (SPID INT,Status VARCHAR(255),
      Login  VARCHAR(255),HostName  VARCHAR(255), 
      BlkBy  VARCHAR(255),DBName  VARCHAR(255), 
      Command VARCHAR(255),CPUTime INT, 
      DiskIO INT,LastBatch VARCHAR(255), 
      ProgramName VARCHAR(255),SPID2 INT, 
      REQUESTID INT,
	  Update_time datetime)

INSERT INTO #sp_who2(SPID,Status,Login,HostName,BlkBy,DBName,Command,CPUTime,DiskIO,LastBatch,ProgramName,SPID2,REQUESTID) EXEC sp_who2
UPDATE #sp_who2 set Update_time=getdate()
--select * from #sp_who2


--可指定SPID，查詢其SQL語法內容
if object_id('tempdb..#inputbuffer') is not null
	drop table #inputbuffer
CREATE TABLE #inputbuffer (SPID varchar(10),id_num int IDENTITY,EventType NVARCHAR(max),Parameters  NVARCHAR(max),EventInfo  NVARCHAR(max));


declare @SQL as nvarchar(max)
set @SQL=''
select @SQL=@SQL+'insert into #inputbuffer(EventType,Parameters,EventInfo) exec(''dbcc inputbuffer('+cast(SPID as varchar(5))+')'');'
+'update #inputbuffer set SPID='''+cast(SPID as varchar(5))+''' where id_num=(select max(id_num) from #inputbuffer where SPID is null);'
from #sp_who2
WHERE DBName <> 'master'

--print @SQL
execute sp_executesql @SQL
--select * from #inputbuffer


--insert into S8200FTPWTS01.HQDB.dbo.DBSource_Record
SELECT     @@SERVERNAME ServerName,a.Update_time,a.SPID,Status,Login,HostName,b.EventInfo,DBName,Command,CPUTime,DiskIO,LastBatch,ProgramName,SPID2
FROM        #sp_who2 a
left join (select SPID,EventType,EventInfo from #inputbuffer group by SPID,EventType,EventInfo) b
on a.SPID=b.SPID
where a.SPID>=50 and Status not in ('DORMANT')
order by Status,CPUTime desc,DiskIO desc,SPID


/*
select *
from HQDB.dbo.DBSource_Record
--WHERE DBName <> 'master'
ORDER BY Update_Time desc,DBName ASC,CPUTime desc,DiskIO desc,LastBatch desc,Login,Command

*/


--刪除指定session
/*
若該session是大量交易，kill會導致DB花費大量時間做recover，人為也無法停止，會佔用系統大量資源
故kill前要先確認其交易內容再執行
*/
--kill 放上spid

/*
select *
from sys.dm_exec_requests

select *
from sys.dm_exec_sessions

select *
from sys.sysprocesses
*/

