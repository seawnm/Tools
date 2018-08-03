--此表僅統計資料量(不含log)

--近期總容量變化情形
if object_id('tempdb..#temp') is not null
	drop table #temp
select * into #temp from (
	select convert(varchar(8),Date,112) Date,ServerName,round(sum(reservedSize_MB)/1024,0) reservedSize_GB
	from YourServerName.FTP.dbo.Table_Size_HIS 
	where ServerName!='S0021RISKDB01'
	group by convert(varchar(8),Date,112),ServerName
) a

select *
from #temp
order by ServerName,Date desc

--取得最近1,2個月的記錄日期
if object_id('tempdb..#date') is not null
	drop table #date
select f,ServerName,Date,Last_Date
into #date
from (
	select 'One_Month' f,a.ServerName,a.Date,b.Date Last_Date,row_number() over(partition by a.ServerName order by a.Date desc,b.Date desc) iid
	from #temp a
	left join #temp b
	on a.ServerName=b.ServerName and dateadd(m,-1,a.Date)>b.Date
	union all
	select 'Two_Month' f,a.ServerName,a.Date,b.Date Last_Date,row_number() over(partition by a.ServerName order by a.Date desc,b.Date desc) iid
	from #temp a
	left join #temp b
	on a.ServerName=b.ServerName and dateadd(m,-2,a.Date)>b.Date
) aa
where iid=1

select a.Date,a.ServerName,a.reservedSize_GB
,b.Last_Date as 前一月_Date,c.reservedSize_GB as 前一月_reservedSize_GB
,cast(round(a.reservedSize_GB*1.0/c.reservedSize_GB*100-100,0) as varchar(100))+'%' as 近一個月增長量
,d.Last_Date as 前二月_Date,e.reservedSize_GB as 前二月_reservedSize_GB
,cast(round(a.reservedSize_GB*1.0/e.reservedSize_GB*100-100,0) as varchar(100))+'%' as 近二個月增長量
from #temp a
join #date b
on a.ServerName=b.ServerName and a.Date=b.Date and b.f='One_Month'
join #temp c
on b.ServerName=c.ServerName and b.Last_Date=c.Date
join #date d
on a.ServerName=d.ServerName and a.Date=d.Date and d.f='Two_Month'
join #temp e
on d.ServerName=e.ServerName and d.Last_Date=e.Date



--取出目前最新日期及最早的記錄日期，以便後續比較用
if object_id('tempdb..#date1') is not null
	drop table #date1
select convert(varchar(8),min(Date),112) min_D,convert(varchar(8),max(Date),112) max_D
into #date1
from YourServerName.FTP.dbo.Table_Size_HIS where ServerName='YourServerName' 
and Date>=dateadd(m,-2,getdate())

--select * from #date1

--top 10
select top 10 convert(varchar(8),Date,112) Date,ServerName,DBName,Table_name,rows,unused,reservedSize_MB,dataSize_MB,indexSize_MB
,'' 處理方式,'' 負責人
from YourServerName.FTP.dbo.Table_Size_HIS 
where ServerName='YourServerName' 
and convert(varchar(8),Date,112)=(select max_D from #date1)
order by reservedSize_MB desc

--已存在的Table近期增長量top 10
select *
from (
	select row_number() over(partition by isnull(a.ServerName,b.ServerName) 
													order by isnull(a.reservedSize_MB,0)-isnull(b.reservedSize_MB,0) desc) as Noid
	,convert(varchar(8),a.Date,112) 本期資料日,convert(varchar(8),b.Date,112) 基期資料日,isnull(a.ServerName,b.ServerName) ServerName
	,isnull(a.DBName,b.DBName) DBName,isnull(a.Table_name,b.Table_name) Table_name
	,isnull(a.reservedSize_MB,0)-isnull(b.reservedSize_MB,0) reservedSize_MB_diff
	,case when b.reservedSize_MB is null or b.reservedSize_MB=0 then 100 else round(isnull(a.reservedSize_MB,0)/isnull(b.reservedSize_MB,0) -1,2)*100 end diff_ratio
	,isnull(a.reservedSize_MB,0) 本期_reservedSize_MB
	,isnull(b.reservedSize_MB,0) 基期_reservedSize_MB
	,'' 處理方式,'' 負責人
	from (
		select *
		from YourServerName.FTP.dbo.Table_Size_HIS 
		where convert(varchar(8),Date,112) in (select max_D from #date1)
		--and ServerName='S0021RISKDB03' 
	) a
	left join (
		select *
		from YourServerName.FTP.dbo.Table_Size_HIS 
		where convert(varchar(8),Date,112) in (select min_D from #date1)
		--and ServerName='S0021RISKDB03' 
	) b
	on a.ServerName=b.ServerName and a.DBName=b.DBName and a.Table_name=b.Table_name
) aa
where Noid<=10
order by ServerName,reservedSize_MB_diff desc

--新建的Table增長量top 20
select *
from (
	select row_number() over(partition by isnull(a.ServerName,b.ServerName) 
													order by isnull(a.reservedSize_MB,0)-isnull(b.reservedSize_MB,0) desc) as Noid
	,convert(varchar(8),a.Date,112) 本期資料日,convert(varchar(8),b.Date,112) 基期資料日,isnull(a.ServerName,b.ServerName) ServerName
	,isnull(a.DBName,b.DBName) DBName,isnull(a.Table_name,b.Table_name) Table_name
	,isnull(a.reservedSize_MB,0)-isnull(b.reservedSize_MB,0) reservedSize_MB_diff
	,case when b.reservedSize_MB is null or b.reservedSize_MB=0 then 100 else round(isnull(a.reservedSize_MB,0)/isnull(b.reservedSize_MB,0) -1,2)*100 end diff_ratio
	,isnull(a.reservedSize_MB,0) 本期_reservedSize_MB
	,isnull(b.reservedSize_MB,0) 基期_reservedSize_MB
	,'' 處理方式,'' 負責人
	from (
		select *
		from YourServerName.FTP.dbo.Table_Size_HIS 
		where convert(varchar(8),Date,112)=(select max_D from #date1)
		--and ServerName='S0021RISKDB03' 
	) a
	left join (
		select *
		from YourServerName.FTP.dbo.Table_Size_HIS 
		where convert(varchar(8),Date,112)=(select min_D from #date1)
		--and ServerName='S0021RISKDB03' 
	) b
	on a.ServerName=b.ServerName and a.DBName=b.DBName and a.Table_name=b.Table_name
	where  b.ServerName is null
) aa
where Noid<=20
order by ServerName,reservedSize_MB_diff desc

--查逐筆變化
select convert(char(8),Date,112) Date,ServerName,DBName,Table_name,rows,unused,reservedSize_MB,dataSize_MB,indexSize_MB
from YourServerName.FTP.dbo.Table_Size_HIS 
where ServerName='YourServerName'
order by DBName,Table_name,Date desc