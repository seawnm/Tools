USE [HQDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_Record_TableSize]    Script Date: 2015/10/16 上午 11:44:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_Record_TableChange] AS


--/* 可用下述語法查詢哪個帳號在做新增刪除修改(但正式機沒權限使用)
if object_id('tempdb..#dbNameList') is not null
	drop table #dbNameList

create table #dbNameList (
	dbname varchar(20)
);

--record db name list
EXECUTE master.sys.sp_MSforeachdb 'insert #dbNameList select ''!'' dbname','!'


declare @SQL as nvarchar(max)
set @SQL=''
select @SQL=@SQL+'
 use '+dbname+';
 insert into YourServerName.HQDB.dbo.Table_Record_HIS
 select @@SERVERNAME ServerName,'''+dbname+''' DBName,*,getdate() update_time
 from (
	select SUSER_SNAME (a.[Transaction SID]) AS [USER],a.[Transaction ID],a.[Begin Time],c.[End Time],a.[Transaction Name]
	,b.Operation,b.AllocUnitName
	from (
		SELECT OPeration,[Transaction ID],[Begin Time],[Transaction Name],Description,[Transaction SID]
		FROM sys.fn_dblog(NULL, NULL)
		WHERE [Operation] = ''LOP_BEGIN_XACT''
	) a join (
		select Operation,Context,[Transaction ID],AllocUnitName
		from sys.fn_dblog(NULL,NULL)
		where OPERATION = ''LOP_DELETE_ROWS'' group by Operation,Context,[Transaction ID],AllocUnitName
	) b on a.[Transaction ID]=b.[Transaction ID]
	join (
		select [Transaction ID],[End Time]
		from sys.fn_dblog(NULL,NULL)
		where OPERATION = ''LOP_COMMIT_XACT''
	) c on a.[Transaction ID]=c.[Transaction ID]
	where b.Context=''LCX_HEAP''
	union all
	select SUSER_SNAME (a.[Transaction SID]) AS [USER],a.[Transaction ID],a.[Begin Time],c.[End Time],a.[Transaction Name]
	,b.Operation,b.AllocUnitName
	from (
		SELECT OPeration,[Transaction ID],[Begin Time],[Transaction Name],Description,[Transaction SID]
		FROM sys.fn_dblog(NULL, NULL)
		WHERE [Operation] = ''LOP_BEGIN_XACT''
	) a join (
		select Operation,Context,[Transaction ID],AllocUnitName
		from sys.fn_dblog(NULL,NULL)
		where OPERATION = ''LOP_INSERT_ROWS'' group by Operation,Context,[Transaction ID],AllocUnitName
	) b on a.[Transaction ID]=b.[Transaction ID]
	join (
		select [Transaction ID],[End Time]
		from sys.fn_dblog(NULL,NULL)
		where OPERATION = ''LOP_COMMIT_XACT''
	) c on a.[Transaction ID]=c.[Transaction ID]
	where b.Context=''LCX_HEAP''
	union all
	select SUSER_SNAME (a.[Transaction SID]) AS [USER],a.[Transaction ID],a.[Begin Time],c.[End Time],a.[Transaction Name]
	,b.Operation,b.AllocUnitName
	from (
		SELECT OPeration,[Transaction ID],[Begin Time],[Transaction Name],Description,[Transaction SID]
		FROM sys.fn_dblog(NULL, NULL)
		WHERE [Operation] = ''LOP_BEGIN_XACT''
	) a join (
		select Operation,Context,[Transaction ID],AllocUnitName
		from sys.fn_dblog(NULL,NULL)
		where OPERATION = ''LOP_MODIFY_ROW'' group by Operation,Context,[Transaction ID],AllocUnitName
	) b on a.[Transaction ID]=b.[Transaction ID]
	join (
		select [Transaction ID],[End Time]
		from sys.fn_dblog(NULL,NULL)
		where OPERATION = ''LOP_COMMIT_XACT''
	) c on a.[Transaction ID]=c.[Transaction ID]
	where b.Context=''LCX_HEAP''
 ) aa;
'
from #dbNameList
where dbname not in ('master','tempdb','msdb','C8DB')

--print @SQL
EXECUTE sp_executesql @SQL

--將同一秒發生的各動作壓縮成同一筆記錄
if object_id('tempdb..#temp') is not null
	drop table #temp
select ServerName,DBName,USERS
,max(Transaction_ID) Transaction_ID,min(Begin_Time) Begin_Time,max(End_Time) End_Time
,Transaction_Name,Operation,AllocUnitName,max(update_time) update_time
into #temp
from YourServerName.HQDB.dbo.Table_Record_HIS
where convert(varchar(8),update_time,112)=convert(varchar(8),getdate(),112)
group by ServerName,DBName,USERS,Transaction_Name,Operation,AllocUnitName,convert(varchar(16),Begin_Time,120),convert(varchar(16),End_Time,120)

delete from YourServerName.HQDB.dbo.Table_Record_HIS
where convert(varchar(8),update_time,112)=convert(varchar(8),getdate(),112)

insert into YourServerName.HQDB.dbo.Table_Record_HIS
select * from #temp



/*  for serach 
--delete from YourServerName.HQDB.dbo.Table_Record_HIS
--Grouping
select *
,left(Begin_Time,11) date
,substring(Begin_Time,12,2) hours
,substring(Begin_Time,15,2) mins
from YourServerName.HQDB.dbo.Table_Record_HIS
--where convert(varchar(8),update_time,112)!='20151023'
--and AllocUnitName='dbo.FTP_Loan_Calculate'
order by Begin_Time,update_time


--*/

