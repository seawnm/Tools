--USE [YourDBName]
GO
/****** Object:  StoredProcedure [dbo].[sp_FC_AbnormalProcess]    Script Date: 2015/8/27 上午 10:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--ALTER PROCEDURE [dbo].[sp_Record_TableSize] AS
/* 記錄Server上所有DB內Table的大小，用以觀察DB容量變化跟警示空間不足用 by Walter */

if object_id('tempdb..#t') is not null
	drop table #t
-- Table row counts and sizes.
CREATE TABLE #t 
( 
    [name] NVARCHAR(128),
    [rows] CHAR(11),
    reserved VARCHAR(18), 
    data VARCHAR(18), 
    index_size VARCHAR(18),
    unused VARCHAR(18)
) 


--儲存各DB之table資訊
if object_id('tempdb..#table_size') is not null
	drop table #table_size
CREATE TABLE #table_size 
( 
	[Date] DATETIME,
	[ServerName] VARCHAR(20),
	[DBName] VARCHAR(15),
    [Table_name] NVARCHAR(128),
    [rows] CHAR(11),
    [unused] VARCHAR(18),
	[reservedSize_MB] NUMERIC(18,0),
	[dataSize_MB] NUMERIC(18,0),
	[indexSize_MB] NUMERIC(18,0)
) 

--if object_id('tempdb..#table_size') is not null
--	drop table #table_size
--SELECT getdate() Date,space(15) DBName,name,rows,unused
--, LTRIM(STR(CAST(LEFT(reserved,LEN(reserved)-3) AS NUMERIC(18,0)) / 1024, 18)) 
--AS reservedSize_MB
--, LTRIM(STR(CAST(LEFT(data,LEN(data)-3) AS NUMERIC(18,0)) / 1024, 18)) 
--AS dataSize_MB
--, LTRIM(STR(CAST(LEFT(index_size,LEN(index_size)-3) AS NUMERIC(18,0)) / 1024, 18)) 
--AS indexSize_MB
--into #table_size
--FROM #t a


EXECUTE master.sys.sp_MSforeachdb 
'
use [!];
if ''!''<>''tempdb''
begin
	delete from #t;
	--把每個Table使用的資訊存到#t之中
	INSERT #t EXEC sys.sp_MSforeachtable ''EXEC sp_spaceused ''''?'''''';

	--依使用空間較大的依序排列並顯示MB
	insert into #table_size
	SELECT getdate() Date,@@SERVERNAME ServerName,''!'' DBName,name,rows,unused
	, LTRIM(STR(CAST(LEFT(reserved,LEN(reserved)-3) AS NUMERIC(18,0)) / 1024, 18)) AS reservedSize_MB
	, LTRIM(STR(CAST(LEFT(data,LEN(data)-3) AS NUMERIC(18,0)) / 1024, 18)) AS dataSize_MB
	, LTRIM(STR(CAST(LEFT(index_size,LEN(index_size)-3) AS NUMERIC(18,0)) / 1024, 18)) AS indexSize_MB
	FROM #t a
	ORDER BY CAST(LEFT(data,LEN(data)-3) AS NUMERIC(18,0)) DESC
end
','!'

--刪除同一天重跑之資料(僅限本Server的記錄)
--delete from YourServerName.YourDBName.dbo.Table_Size_HIS 
--where convert(varchar(8),Date,112)=convert(varchar(8),getdate(),112) and ServerName=@@SERVERNAME

--insert into YourServerName.YourDBName.dbo.Table_Size_HIS 
select Servername,DBName,Table_name,rows,dataSize_MB/1024 as dataSize_GB
from #table_size
where DBName='DevDB_FTP'
order by dataSize_MB desc

----只保留近3個月週記錄和全部月底日之記錄
--delete from YourServerName.YourDBName.dbo.Table_Size_HIS 
--where Date<dateadd(m,-3,getdate())
--and Date not in (select max(Date) from YourServerName.YourDBName.dbo.Table_Size_HIS S group by convert(varchar(6),Date,112))
--and ServerName=@@SERVERNAME


/*
exec YourDBName..sp_Record_TableSize

select *
from YourDBName..Table_Size_HIS
order by convert(varchar(8),Date,112) desc

*/
