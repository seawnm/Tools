--找出各Table所有可能是日期的欄位
if object_id('tempdb..#tableDetails') is not null
	drop table #tableDetails
SELECT dbo.sysobjects.name AS sTableName
,dbo.syscolumns.name AS sColumnsName
,dbo.systypes.name AS sColumnsType
,cast(dbo.syscolumns.prec as varchar(5)) as sColumnsLength
,space(8) minValue,space(8) maxValue
,row_number() over(order by dbo.sysobjects.name,dbo.syscolumns.colorder) number
into #tableDetails
FROM dbo.sysobjects INNER JOIN
dbo.syscolumns ON dbo.sysobjects.id = dbo.syscolumns.id INNER JOIN
dbo.systypes ON dbo.syscolumns.xusertype = dbo.systypes.xusertype
where dbo.sysobjects.xtype='U' and (dbo.systypes.name in ('smalldatetime','datetime') or
(dbo.systypes.name in ('char','nchar','varchar','nvarchar')
and cast(dbo.syscolumns.prec as varchar(5)) in (4,6,8)))
order by dbo.sysobjects.name,dbo.syscolumns.colorder 

/*
select * --delete
from #tableDetails
where minValue='' and maxValue=''
*/

--逐欄位檢查其min,max值，以便判斷資料的期間
declare @SQL as nvarchar(max),@i as int
set @SQL=''
set @i=1
while @i<=(select max(number) from #tableDetails)
begin
	--一次只檢查500個欄位，避免@SQL字串爆掉
	select @SQL=
	case when @SQL is null then 
	'update #tableDetails set minValue=b.minVal,maxValue=b.maxVal
	from #tableDetails a join (
		select '''+sTableName+''' tableName,'''+sColumnsName+''' columnsName
		,case when isnumeric('+sColumnsName+')=1 then max(convert(varchar(8),'+sColumnsName+',112)) else null end maxVal
		,case when isnumeric('+sColumnsName+')=1 then min(convert(varchar(8),'+sColumnsName+',112)) else null end minVal
		from '+sTableName+'
		where case when len('+sColumnsName+')=6 then isdate('+sColumnsName+'+''01'') else isdate('+sColumnsName+') end=1
		group by '+sColumnsName+'
	) b on b.tableName=a.sTableName and b.columnsName=a.sColumnsName;
	where number between '+cast(@i as varchar(5))+' and '+cast((@i+500) as varchar(5))
	else @SQL+
	'update #tableDetails set minValue=b.minVal,maxValue=b.maxVal
	from #tableDetails a join (
		select '''+sTableName+''' tableName,'''+sColumnsName+''' columnsName
		,case when isnumeric('+sColumnsName+')=1 then max(convert(varchar(8),'+sColumnsName+',112)) else null end maxVal
		,case when isnumeric('+sColumnsName+')=1 then min(convert(varchar(8),'+sColumnsName+',112)) else null end minVal
		from '+sTableName+'
		where case when len('+sColumnsName+')=6 then isdate('+sColumnsName+'+''01'') else isdate('+sColumnsName+') end=1
		group by '+sColumnsName+'
	) b on b.tableName=a.sTableName and b.columnsName=a.sColumnsName;
	where number between '+cast(@i as varchar(5))+' and '+cast((@i+500) as varchar(5))
	end
	from #tableDetails where minValue='' and maxValue=''

--	select @SQL
	EXECUTE sp_executesql @SQL

	--一次只檢查500個欄位，避免@SQL字串爆掉
	set @i=@i+501	
end

