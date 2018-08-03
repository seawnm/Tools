--查詢各DB Table欄位
--建立暫存table
if object_id('tempdb..#t') is not null
	drop table #t
create table #t(
	ServerName varchar(100)
	,APName varchar(100)
	,DBName varchar(100)
	,TableID varchar(10)
	,TableName varchar(200)
	,TableName_DESC varchar(500)
	,ColumnsID varchar(10)
	,ColumnsName varchar(500)
	,ColumnsName_DESC nvarchar(max)
	,ColumnsName_SPEC nvarchar(max)
	,ColumnsType varchar(200)
	,UpdateTime datetime
)


--建立Table欄位資訊
EXECUTE master.sys.sp_MSforeachdb
--print 
' use [?];

 --遇到系統DB不記錄,加快速度
 if (select case when ''?'' in (''master'',''msdb'',''tempdb'') then ''Y'' end)=''Y''
	 return;

 --建立Table Series ID
 if object_id(''tempdb..#t2'') is not null
  	 drop table #t2
 select ''?'' DBName,row_number() over(order by name) TableID,name TableName
 into #t2
 from sysobjects
 where type IN (''U'',''V'')
 order by name

 insert into #t
 SELECT @@Servername ServerName,null APName,''?'' DBName,e.TableID,a.name TableName,null TableName_DESC,c.colorder as ColumnsID
 ,c.name AS ColumnsName,null ColumnsName_DESC,null ColumnsName_SPEC
 ,d.name + ''(''+ cast(c.prec as varchar(5))+'')'' AS ColumnsType,getdate()
 FROM sys.sysobjects a
 left join sys.all_objects b on a.name = b.name
 INNER JOIN sys.syscolumns c ON a.id = c.id 
 INNER JOIN sys.systypes d ON c.xusertype = d.xusertype
 left join #t2 e on a.name=e.TableName collate Chinese_Taiwan_Stroke_CI_AS
 where a.type IN (''U'',''V'')
 order by a.name,c.colorder 
'

select ServerName,DBName,count(1) nums
from #t
group by ServerName,DBName
order by ServerName,DBName


select *
from #t

