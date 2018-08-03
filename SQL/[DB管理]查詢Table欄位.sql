--查詢各DB Table欄位
--建立暫存table
if object_id('tempdb..#t') is not null
	drop table #t
SELECT space(50) ServerName,space(50) DBName,space(5) TableID,a.name TableName,c.colorder as ColumnsID,c.name AS ColumnsName
,d.name + '('+ cast(c.prec as varchar(5))+')' AS ColumnsType
into #t
FROM sysobjects a
left join sys.all_objects b on a.name = b.name
INNER JOIN dbo.syscolumns c ON a.id = c.id 
INNER JOIN dbo.systypes d ON c.xusertype = d.xusertype
where 1=0


--建立Table欄位資訊
EXECUTE master.sys.sp_MSforeachdb
--print 
' use [?];
 --建立Table Series ID
 if object_id(''tempdb..#t2'') is not null
  	 drop table #t2
 select ''?'' DBName,row_number() over(order by name) TableID,name TableName
 into #t2
 from sysobjects
 where type IN (''U'',''V'')
 order by name

 insert into #t
 SELECT @@Servername ServerName,''?'' DBName,e.TableID,a.name TableName,c.colorder as ColumnsID,c.name AS ColumnsName
 ,d.name + ''(''+ cast(c.prec as varchar(5))+'')'' AS ColumnsType
 FROM sysobjects a
 left join sys.all_objects b on a.name = b.name
 INNER JOIN dbo.syscolumns c ON a.id = c.id 
 INNER JOIN dbo.systypes d ON c.xusertype = d.xusertype
 left join #t2 e on a.name=e.TableName collate Chinese_Taiwan_Stroke_CI_AS
 where a.type IN (''U'',''V'')
 order by a.name,c.colorder 
'

select *
from #t
order by DBName,TableName
