-- All Stats begin count since last server restart.

-- 1. Return All Index Stats on Database

SELECT
		o.name AS object_name,
		i.name AS NameOfIndex,
		i.type_desc as IsItClustered,
		u.user_seeks as IndexSeeks, 
		u.user_scans as IndexScans,
		u.user_lookups as IndexLookups, 
		u.user_seeks + u.user_scans + u.user_lookups as user_reads,
		u.user_updates as user_writes,
		(user_seeks + user_scans + user_lookups) - user_updates as Diff,	-- Positive Numbers for reads negative for Writes
		o.type
	FROM sys.indexes i
	INNER JOIN sys.objects o 
		ON i.object_id = o.object_id
	LEFT JOIN sys.dm_db_index_usage_stats u 
		ON i.object_id = u.OBJECT_ID
		AND i.index_id = u.index_id
		AND u.database_id = DB_ID()
	WHERE o.type IN ('U', 'V') AND
		i.name IS NOT NULL
	--ORDER BY o.name, i.name	-- by object
	ORDER BY Diff desc

-- 2. get detailed read/write stats on all indexes, looking for those where the maintenance burden may outweigh their usefulness in boosting query performance.

	SELECT  
		'[' + DB_NAME() + '].[' + su.name + '].[' + o.name + ']' AS statement,
		i.name AS index_name,
		ddius.user_seeks + ddius.user_scans + ddius.user_lookups AS user_reads,
		ddius.user_updates AS user_writes,
		SUM(SP.rows) AS total_rows
	FROM sys.dm_db_index_usage_stats ddius
	INNER JOIN sys.indexes i 
		ON ddius.object_id = i.object_id
		AND i.index_id = ddius.index_id
	INNER JOIN sys.partitions SP 
		ON ddius.object_id = SP.object_id
		AND SP.index_id = ddius.index_id
	INNER JOIN sys.objects o 
		ON ddius.object_id = o.object_id
	INNER JOIN sys.schemas su 
		ON o.schema_id = su.schema_id
	WHERE ddius.[database_id] = DB_ID() -- current database only
		AND OBJECTPROPERTY(ddius.object_id, 'IsUserTable') = 1
		AND ddius.index_id > 0	-- Clustered and NonClustered Indexes
	GROUP BY 
		su.name,
		o.name,
		i.name,
		ddius.user_seeks + ddius.user_scans + ddius.user_lookups,
		ddius.user_updates
	HAVING  ddius.user_seeks + ddius.user_scans + ddius.user_lookups = 0
	--ORDER BY 1		--Orders by the objects (tables)
	ORDER BY ddius.[user_updates] DESC ,	-- Orders by most updates desc (worst offenders)
			su.[name] ,
			o.[name] ,
			i.[name]

-- 3. Index Fragmentation

	SELECT 
		schema_name(t.schema_id) AS [Schema],
		object_name(ps.object_id) AS [Table],
		i.name AS [Index],
		ps.Index_type_desc AS IndexType,
		convert(TINYINT,ps.avg_fragmentation_in_percent) AS [AvgFrag%],
		convert(TINYINT,ps.avg_page_space_used_in_percent) AS [AvgSpaceUsed%],
		ps.record_count AS RecordCnt,
		ps.fragment_count AS FragmentCnt,
		ps.page_count
	FROM sys.dm_db_index_physical_stats(db_id(db_name()), NULL,NULL,NULL,'DETAILED') ps -- Faster option: SAMPLED (but is only approx)
	INNER JOIN sys.indexes i
		ON ps.object_id = i.object_id
		AND ps.index_id = i.index_id
	INNER JOIN sys.tables t 
		ON ps.object_id = t.object_id
	WHERE t.is_ms_shipped = 0
		and ps.avg_fragmentation_in_percent > 30
	ORDER BY [AvgFrag%] DESC

-- 4. Return all Metrics for Tables that are Heaps (No Indexes)
	-- This will return objects that may have "ONLY" a non-clustered index. Compare against the #1 script to verify that there are 0 indexes on object.

	SELECT  
		'[' + DB_NAME() + '].[' + su.name + '].[' + o.name + ']' AS statement,
		i.name AS index_name,
		ddius.user_seeks + ddius.user_scans + ddius.user_lookups AS user_reads,
		ddius.user_updates AS user_writes,
		SUM(SP.rows) AS total_rows
	FROM sys.dm_db_index_usage_stats ddius
	INNER JOIN sys.indexes i 
		ON ddius.object_id = i.object_id
		AND i.index_id = ddius.index_id
	INNER JOIN sys.partitions SP 
		ON ddius.object_id = SP.object_id
		AND SP.index_id = ddius.index_id
	INNER JOIN sys.objects o 
		ON ddius.object_id = o.object_id
	INNER JOIN sys.schemas su 
		ON o.schema_id = su.schema_id
	WHERE ddius.[database_id] = DB_ID() -- current database only
		AND OBJECTPROPERTY(ddius.object_id, 'IsUserTable') = 1
		AND ddius.index_id = 0 -- HEAP
	GROUP BY 
		su.name,
		o.name,
		i.name,
		ddius.user_seeks + ddius.user_scans + ddius.user_lookups,
		ddius.user_updates
	ORDER BY ddius.[user_updates] DESC ,	-- Orders by most updates desc (worst offenders)
			su.[name] ,
			o.[name] ,
			i.[name]