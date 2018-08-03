--drop table #t
select space(50) DBName, DBRole = g.name, MemberName = u.name into #t
From sys.database_principals u, sys.database_principals g, sys.database_role_members m
Where g.principal_id = m.role_principal_id And u.principal_id = m.member_principal_id and 1=0

delete from #t
EXECUTE master.sys.sp_MSforeachdb
'USE [?]; insert into #t
 select ''?'' DBName, DBRole = g.name, MemberName = u.name
 From sys.database_principals u, sys.database_principals g, sys.database_role_members m
 Where g.principal_id = m.role_principal_id And u.principal_id = m.member_principal_id
 Order by 1, 2, 3'

/* 列出帳號清單
select distinct MemberName from #t 
where MemberName not in ('dbadmin','dbo','S0021RISKDB01\is_admin','SQLAgentOperatorRole','SQLAgentReaderRole','objmgr')
order by MemberName
--*/


select '' ServerName,DBName,MemberName,DBRole
from #t 
where MemberName not in 
('dbadmin','dbo','S0021RISKDB01\is_admin','SQLAgentOperatorRole','SQLAgentReaderRole','objmgr'
,'scca1','scca2','BUILTIN\Administrators','sts_user','apsa')
and MemberName not like 'aspnet_%'
Order by DBName,MemberName,DBRole







