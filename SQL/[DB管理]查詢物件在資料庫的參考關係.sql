--找出各Table,SP,View會被哪些object存取
if object_id('tempdb..#result') is not null
	drop table #result
select space(50) DBName,space(100) name,xtype 物件類型,crdate
,space(100) "包含於",xtype "(包含於)物件類型" 
,space(500) "搜尋到的附近內文"
,cast(space(500) as varchar(max)) "完整內文"
into #result
from sysobjects
where 1=0


if object_id('tempdb..#db') is not null
	drop table #db
select space(50) dbname
into #db


EXECUTE master.sys.sp_MSforeachdb
--print 
'use [?]

insert into #db select ''?''

if ''?''!=''master'' and ''?''!=''tempdb'' and ''?''!=''msdb''
begin	
	if object_id(''tempdb..#temp'') is not null
		drop table #temp
	select aa.name,aa.xtype,aa.crdate
	,bb.name "包含於",bb.xtype xtype_
	,''... ''+substring(bb.text,CHARINDEX(aa.name,text)-5,50)+'' ...'' "搜尋到的附近內文"
	,bb.text "完整內文"
	into #temp
	from (
		select a.name,a.id,a.xtype,a.crdate
		from sysobjects a
		where xtype in (''FN'',''P'',''U'',''V'')
	) aa
	left join (
		select a.name,a.xtype,a.id,b.colid,text
		from sysobjects a
		left join syscomments b
		on a.id=b.id
		where xtype in (''FN'',''P'',''V'')
	) bb
	on aa.id!=bb.id
	--只找出有被包含到的物件
	where CHARINDEX(aa.name,bb.text)!=0

	insert into #result
	select ''?'',a.name
	,a.xtype 物件類型
	,a.crdate
	,ISNULL(b.包含於,'''')
	,ISNULL(b.xtype_,'''') "(包含於)物件類型"
	,ISNULL(b.搜尋到的附近內文,'''')
	,ISNULL(b.完整內文,'''')
	from sysobjects a
	left join #temp b on a.name=b.name
	where a.xtype in (''FN'',''P'',''U'',''V'')
end
'

select * from #result
order by name,包含於
