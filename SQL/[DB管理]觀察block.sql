--第一個Query 的blocking_session指的是有block狀況(50以內為系統thread不用管，
--50以上可參考blocking(第二query)，考慮是否要刪block的thread

--Session Status
select session_id,status,wait_type,last_wait_type,command,blocking_session_id,
db_name(rs.database_id) as DBname,qt.text
,qp.query_plan
,wait_time,
percent_complete,estimated_completion_time,cpu_time,total_elapsed_time,
reads,writes,logical_reads,start_time
 from sys.dm_exec_requests rs
cross apply sys.dm_exec_sql_text(rs.sql_handle) as qt
cross apply sys.dm_exec_query_plan(rs.plan_handle) as qp
OPTION (RECOMPILE);

--Find RootBlocking
WITH RootBlocking AS
 (
     SELECT DISTINCT blocking_session_id FROM sys.dm_exec_requests 
     WHERE blocking_session_id > 50 
     AND blocking_session_id  not In 
         ( SELECT session_id FROM sys.dm_exec_requests WHERE blocking_session_id > 50 )
 )
 SELECT ses.session_id,ses.host_name,ses.program_name,ses.login_name,ses.status, ses.last_request_end_time,
     ct1.text sql_text,ct2.text recent_sql_text
 FROM RootBlocking rot
 INNER JOIN sys.dm_exec_connections con ON rot.blocking_session_id = con.session_id
 INNER JOIN sys.dm_exec_sessions ses ON rot.blocking_session_id = ses.session_id
 LEFT  JOIN sys.dm_exec_requests req ON rot.blocking_session_id = req.session_id
 OUTER APPLY sys.dm_exec_sql_text(req.sql_handle) ct1
 OUTER APPLY sys.dm_exec_sql_text(con.most_recent_sql_handle) ct2


 