if object_id('tempdb..#t') is not null
	drop table #t
SELECT space(50) ServerName,space(50) DBName,a.name,a.type,b.type_desc
into #t
FROM sysobjects a
left join sys.all_objects b on a.name = b.name
where a.type IN ('U','V','P','FN') and 1=0
order by a.type,a.name

delete from #t
EXECUTE master.sys.sp_MSforeachdb
'USE [?]; insert into #t
SELECT @@SERVERNAME ServerName,''?'' DBName,a.name,a.type,b.type_desc
FROM sysobjects a
left join sys.all_objects b on a.name = b.name
where a.type IN (''U'',''V'',''P'',''FN'')'

select * from #t 
--where DBName='DevDB_FTP'
Order by 2,4,3
