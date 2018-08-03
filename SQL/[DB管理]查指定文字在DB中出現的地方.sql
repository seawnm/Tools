--找出指定的文字會被哪些object存取
if object_id('tempdb..#keywords') is not null
	drop table #keywords
create table #keywords (KeyWord varchar(100))

--*********   輸入要指定搜尋的文字(若有多組可用union串)   *********--

insert into #keywords
select 'CheckResult_DepositStandard'
 

--*********   輸入要指定搜尋的文字(若有多組可用union串)   *********--



if object_id('tempdb..#result') is not null
	drop table #result
create table #result(
	ServerName varchar(50)
	,DBName varchar(50)
	,KeyWord varchar(100)
	,[包含於] varchar(100)
	,[(包含於)物件類型] varchar(30)
	,[段落] int
	,[位置(字元)] int
	,[搜尋到的附近內文] varchar(500)
)

--暫存用
if object_id('tempdb..#stage') is not null
	drop table #stage
select 9999 i,* into #stage from #result

declare @SQL as nvarchar(max)
set @SQL=
--print 
'use [?]

--initial
delete from #stage

declare @i as int
set @i=1

--exclude system db
if ''?''!=''master'' and ''?''!=''tempdb'' and ''?''!=''msdb''
begin
	while 1=1
	begin
		insert into #stage
		select @i,@@SERVERNAME ServerName,''?'' DBName,aa.KeyWord KeyWord
		,bb.name [包含於],bb.xtype xtype_,bb.colid [段落]
		,CHARINDEX(aa.KeyWord collate database_default,bb.text,isnull(cc.[位置(字元)]+1,0)) [位置(字元)]
		,''"... ''+substring(bb.text,CHARINDEX(aa.KeyWord collate database_default,text,isnull(cc.[位置(字元)]+1,0))-20,100)+'' ..."'' [搜尋到的附近內文]
		from #keywords aa
		left join (
			select a.name,a.xtype,a.id,b.colid,text
			from sysobjects a
			left join syscomments b
			on a.id=b.id
			where xtype in (''FN'',''U'',''P'',''V'')
		) bb on 1=1
		left join (
			select DBName,KeyWord,包含於,[(包含於)物件類型],段落,max([位置(字元)]) [位置(字元)] from #stage
			group by DBName,KeyWord,包含於,[(包含於)物件類型],段落
		) cc
		on ''?''=cc.DBName and aa.KeyWord=cc.KeyWord 
		and bb.name=cc.[包含於] collate database_default 
		and bb.colid=cc.[段落]
		--只找出有被包含到的物件
		where CHARINDEX(aa.KeyWord collate database_default,bb.text,isnull(cc.[位置(字元)]+1,0))!=0 and aa.KeyWord!=''''

		insert into #result 
		select ServerName,DBName,KeyWord,包含於,[(包含於)物件類型],段落,[位置(字元)],搜尋到的附近內文 from #stage where i=@i

		if (select count(*) from #stage where i=@i)=0
		--if(@i>2)
		begin
			--out of loop
			break
		end

		set @i=@i+1		
	end
end
'

EXECUTE master.sys.sp_MSforeachdb @SQL


select * from #result
order by KeyWord,DBName,[包含於],段落,[位置(字元)]


