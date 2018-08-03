if object_id('tempdb..#t') is not null
	drop table #t
SELECT space(50)  ServerName,space(50)  DBName,OBJECT_NAME(ic.object_id) obj_name,i.name AS index_name,COL_NAME(ic.object_id,ic.column_id) AS column_name,i.type_desc
,ic.index_column_id,ic.key_ordinal,ic.is_included_column  
into #t
FROM sys.indexes AS i  
INNER JOIN sys.index_columns AS ic   
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id  
INNER JOIN sysobjects as sy
	ON i.object_id=sy.id and sy.type='U'
where 1=0


delete from #t
EXECUTE master.sys.sp_MSforeachdb
'USE [?]; insert into #t
SELECT @@SERVERNAME ServerName,''?'' DBName,OBJECT_NAME(ic.object_id) obj_name,i.name AS index_name,COL_NAME(ic.object_id,ic.column_id) AS column_name,i.type_desc
,ic.index_column_id,ic.key_ordinal,ic.is_included_column  
FROM sys.indexes AS i  
INNER JOIN sys.index_columns AS ic   
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id  
INNER JOIN sysobjects as sy
	ON i.object_id=sy.id and sy.type=''U'''

select * from #t 
where DBName not in ('msdb') and DBName in ('HQDB')
Order by 2,4,3



/*
--直接查詢目前DB的index list
SELECT @@SERVERNAME ServerName,OBJECT_NAME(ic.object_id) obj_name,i.name AS index_name,COL_NAME(ic.object_id,ic.column_id) AS column_name,i.type_desc
,ic.index_column_id,ic.key_ordinal,ic.is_included_column  
FROM sys.indexes AS i  
INNER JOIN sys.index_columns AS ic   
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id  
INNER JOIN sysobjects as sy
	ON i.object_id=sy.id and sy.type='U'
order by obj_name,index_column_id

*/