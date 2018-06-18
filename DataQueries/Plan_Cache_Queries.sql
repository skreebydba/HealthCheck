/* 
Name: Plan_Cache_Queries.sql 
Purpose: Find most resource-intensive queries in plan cache. 
Date updated: 2015/04/03 
Permissions needed to run: VIEW SERVER STATE 
Notes: 
	Four options for sorting in WHERE clause. 
	Adapted from Troubleshooting SQL Server A Guide for the Accidental DBA http://www.red-gate.com/community/books/accidental-dba. 
*/

INSERT INTO Concurrency.hlthchk.OptimizerInfo
([Counter]
,[Occurrence]
,[Value])
select [counter],
[occurrence],
[value]
from sys.dm_exec_query_optimizer_info

--SELECT TOP (10) 
--	REPLACE(SUBSTRING(ST.text, ( QS.statement_start_offset / 2 ) + 1, 100), CHAR(13) + CHAR(10), ' '), 

INSERT INTO Concurrency.hlthchk.PlanCache
(StatementText
,ExecutionCount
,TotalWorkerTimeMs
,AvgWorkerTimeMs
,TotalLogicalReads
,AvgLogicalReads
,TotalElapsedTimeMs
,AvgElapsedTimeMs
,CreationTime
,LastExecutionTime
,HoursInCache
,DatabaseName)
SELECT TOP (10) 
	SUBSTRING(ST.text, ( QS.statement_start_offset / 2 ) + 1,
		( ( CASE statement_end_offset
		WHEN -1 THEN DATALENGTH(st.text)
		ELSE QS.statement_end_offset
		END - QS.statement_start_offset ) / 2 ) + 1) AS statement_text ,
	execution_count ,
	total_worker_time / 1000 AS total_worker_time_ms ,
	( total_worker_time / 1000 ) / execution_count AS avg_worker_time_ms ,
	total_logical_reads ,
	total_logical_reads / execution_count AS avg_logical_reads ,
	total_elapsed_time / 1000 AS total_elapsed_time_ms ,
	( total_elapsed_time / 1000 ) / execution_count AS avg_elapsed_time_ms ,
	qs.creation_time, 
	qs.last_execution_time,
	DATEDIFF(hh, qs.creation_time, qs.last_execution_time) AS hours_in_cache,
	--qp.query_plan, 
	ISNULL(DB_NAME(st.dbid), 'N/A') AS DatabaseName--,  --Only available for ad hoc or prepared statements
	--qs.plan_handle 
FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY 
	total_worker_time DESC  
	--total_logical_reads DESC 
	--total_elapsed_time_ms DESC 
	--execution_count DESC