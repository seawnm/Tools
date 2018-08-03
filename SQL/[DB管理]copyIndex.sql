CREATE PROCEDURE [dbo].[copyIndex] 
	@ref_db varchar(100) --做為index參考的table所在DB
	,@ref_table varchar(500) --做為index參考的table
	,@use_db varchar(100) --要套用index的table所在DB
	,@use_table varchar(500) --要套用index的table
WITH EXECUTE AS OWNER 
AS
	/* TEST BLOCK
	--drop procedure copyIndex
	declare @ref_db varchar(100),@ref_table varchar(500),@use_db varchar(100),@use_table varchar(500)
	set @ref_db='HQDB'
	set @ref_table='Stru_LCR_Deposit_Standard_Table1'
	set @use_db='HQDB'
	set @use_table='LCR_Deposit_Standard_Table_201606'	
	--*/

	declare @SQL as nvarchar(500)
	--建立一個簡單temp table，用來接住動態SQL內的結果
	if object_id('tempdb..#error') is not null
		drop table #error
	create table #error(col1 int);

	--確認傳入的table name是否正確
	set @SQL='
	if object_id('''+@ref_db+'..'+@ref_table+''') is null or object_id('''+@use_db+'..'+@use_table+''') is null
	begin
		insert into #error select 1
	end
	'
	--print @SQL
	EXEC sp_sqlexec @SQL

	if (select count(*) from #error)>0
	begin
		RAISERROR ('[Error]Cannot find tables, please check it',11,-1); 
		return
	end


	--取出index相關資訊
	if object_id('tempdb..#indexes') is not null
		drop table #indexes
	if object_id('tempdb..#index_columns') is not null
		drop table #index_columns
	if object_id('tempdb..#syscolumns') is not null
		drop table #syscolumns
	select * into #indexes from sys.indexes where 1=0
	select * into #index_columns from sys.index_columns where 1=0
	select * into #syscolumns from dbo.syscolumns where 1=0
	
	set @SQL='
		insert into #indexes select * from '+@ref_db+'.sys.indexes;
		insert into #index_columns select * from '+@ref_db+'.sys.index_columns;
		insert into #syscolumns select * from '+@ref_db+'.dbo.syscolumns;
	'
	--print @SQL
	EXEC sp_sqlexec @SQL


	--組出ref_table的index語法
	set @SQL=''
	SELECT 
	@SQL=@SQL+cc.name+','
	--i.name AS index_name,cc.name AS column_name,ic.index_column_id,ic.key_ordinal,ic.is_included_column  
	FROM #indexes AS i  
	INNER JOIN #index_columns AS ic   
		ON i.object_id = ic.object_id AND i.index_id = ic.index_id  
	INNER JOIN #syscolumns cc ON i.object_id = cc.id and ic.column_id=cc.colid
	WHERE i.object_id = OBJECT_ID(@ref_db+'..'+@ref_table)
	order by ic.key_ordinal;

	if @SQL=''
	begin
		RAISERROR ('[Error]No index info',11,-1)
	end else begin
		--將index語法套用到use_table上
		set @SQL='create index auto_idx on '+@use_db+'..'+@use_table+'('+left(@SQL,len(@SQL)-1)+')'
		EXEC sp_sqlexec @SQL
		print '[OK]SQL:'+@SQL;
	end


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