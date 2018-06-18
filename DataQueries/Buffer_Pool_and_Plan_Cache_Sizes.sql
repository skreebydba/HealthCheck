/* 
Name: Buffer_Pool_and_Plan_Cache_Sizes.sql
Purpose: View buffer pool total size and size per database; view plan cache size and distribution. 
Date updated: 2015/04/02 
	2015/07/10 - JB - Changed plan cache - it said mb, was kb. Also added mb. 
	2015/11/12 - JB - added avg_usage and avg_size to plan cache 
	2017/01/06 - JB - revised for larger use counts 
Permissions needed to run:  VIEW SERVER STATE 
Notes: 
	Buffer Pool query modified from MSDN: https://msdn.microsoft.com/en-us/library/ms173442.aspx 


*/ 

/*Buffer pool size */
INSERT INTO Concurrency.hlthchk.BufferPoolSize
(DatabaseName
,CachedPagesCount
,SizeMb)
SELECT CASE database_id 
        WHEN 32767 THEN 'ResourceDb' 
        ELSE DB_NAME(database_id) 
        END AS database_name , 
	CAST(COUNT(page_id) AS BIGINT) AS cached_pages_count, 
	--(CAST(COUNT(page_id) AS BIGINT))*8192 AS size_bytes, 
	--((CAST(COUNT(page_id) AS BIGINT))*8192)/1024 AS size_kb, 
	(((CAST(COUNT(page_id) AS BIGINT))*8192)/1024)/1024 AS size_mb  
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id 
ORDER BY cached_pages_count DESC;


/*
Plan Cache size and distribution 
	You can choose your ORDER BY clause by un-commenting lines.
*/ 

INSERT INTO Concurrency.hlthchk.CacheSize
(ObjectType
,CountPlans
,CountUses
,AvgUsage
,TotalSizeKb
,TotalSizeMb
,AvgSizeKb)
SELECT 
	CASE 
		WHEN objtype = 'Proc' THEN 'Stored procedure'
		WHEN objtype = 'Prepared' THEN 'Prepared statement'
		WHEN objtype = 'Adhoc' THEN 'Ad hoc query'
		WHEN objtype = 'ReplProc' THEN 'Replication-filter-procedure'
		WHEN objtype = 'Trigger' THEN 'Trigger'
		WHEN objtype = 'View' THEN 'View'
		WHEN objtype = 'Default' THEN 'Default'
		WHEN objtype = 'UsrTab' THEN 'User table'
		WHEN objtype = 'SysTab' THEN 'System table'
		WHEN objtype = 'Check' THEN 'CHECK constraint'
		WHEN objtype = 'Rule' THEN 'Rule'
	END AS object_type, 
	COUNT(objtype) AS count_plans, 
	SUM(CAST(usecounts AS BIGINT)) AS count_uses, 
	(SUM(CAST(usecounts AS BIGINT)))/COUNT(objtype) AS avg_usage, 
	SUM(size_in_bytes/1024) as total_size_kb, 
	SUM(size_in_bytes/1024)/1024 as total_size_mb, 
	(SUM(size_in_bytes/1024)) / COUNT(objtype) AS avg_size_kb 
FROM sys.dm_exec_cached_plans 
GROUP BY objtype
ORDER BY 
	objtype 
