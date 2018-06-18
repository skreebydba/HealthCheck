/*
Name: Wait_Stats.sql
Purpose: List of wait stats since server was last restarted. 
Date updated: 2015/04/01 
Permissions needed to run: VIEW SERVER STATE 
Notes: 
	The list of ignorable wait types will probably need to be added to. 
	List of wait types: https://msdn.microsoft.com/en-us/library/ms179984.aspx 

Run this script all at once. 
*/

--How long has server been up? 
SELECT sqlserver_start_time, 
DATEDIFF(ss, sqlserver_start_time, GETDATE()) AS seconds_since_restart,
DATEDIFF(mi, sqlserver_start_time, GETDATE()) AS minutes_since_restart, 
DATEDIFF(hh, sqlserver_start_time, GETDATE()) AS hours_since_restart, 
DATEDIFF(dd, sqlserver_start_time, GETDATE()) AS days_since_restart 
FROM sys.dm_os_sys_info; 

IF OBJECT_ID('tempdb.dbo.#WaitsToIgnore') IS NOT NULL
BEGIN

	DROP TABLE #waitstoignore;

END

CREATE TABLE #WaitsToIgnore
(wait_type nvarchar(60)) 

--Have to do one at a time, in case we run into a SQL Server 2005 instance. 
INSERT #WaitsToIgnore VALUES ('SLEEP_TASK');
INSERT #WaitsToIgnore (wait_type) VALUES ('REQUEST_FOR_DEADLOCK_SEARCH');
INSERT #WaitsToIgnore (wait_type) VALUES ('SQLTRACE_INCREMENTAL_FLUSH_SLEEP');
INSERT #WaitsToIgnore (wait_type) VALUES ('SQLTRACE_BUFFER_FLUSH');
INSERT #WaitsToIgnore (wait_type) VALUES ('LAZYWRITER_SLEEP');
INSERT #WaitsToIgnore (wait_type) VALUES ('XE_TIMER_EVENT');
INSERT #WaitsToIgnore (wait_type) VALUES ('XE_DISPATCHER_WAIT');
INSERT #WaitsToIgnore (wait_type) VALUES ('FT_IFTS_SCHEDULER_IDLE_WAIT');
INSERT #WaitsToIgnore (wait_type) VALUES ('LOGMGR_QUEUE');
INSERT #WaitsToIgnore (wait_type) VALUES ('CHECKPOINT_QUEUE');
INSERT #WaitsToIgnore (wait_type) VALUES ('BROKER_TO_FLUSH');
INSERT #WaitsToIgnore (wait_type) VALUES ('BROKER_TASK_STOP');
INSERT #WaitsToIgnore (wait_type) VALUES ('BROKER_EVENTHANDLER');
INSERT #WaitsToIgnore (wait_type) VALUES ('SLEEP_TASK');
INSERT #WaitsToIgnore (wait_type) VALUES ('WAITFOR');
INSERT #WaitsToIgnore (wait_type) VALUES ('DBMIRROR_DBM_MUTEX')
INSERT #WaitsToIgnore (wait_type) VALUES ('DBMIRROR_EVENTS_QUEUE')
INSERT #WaitsToIgnore (wait_type) VALUES ('DBMIRRORING_CMD');
INSERT #WaitsToIgnore (wait_type) VALUES ('DISPATCHER_QUEUE_SEMAPHORE');
INSERT #WaitsToIgnore (wait_type) VALUES ('BROKER_RECEIVE_WAITFOR');
INSERT #WaitsToIgnore (wait_type) VALUES ('CLR_AUTO_EVENT');
INSERT #WaitsToIgnore (wait_type) VALUES ('DIRTY_PAGE_POLL');
INSERT #WaitsToIgnore (wait_type) VALUES ('HADR_FILESTREAM_IOMGR_IOCOMPLETION');
INSERT #WaitsToIgnore (wait_type) VALUES ('ONDEMAND_TASK_QUEUE');
INSERT #WaitsToIgnore (wait_type) VALUES ('FT_IFTSHC_MUTEX');
INSERT #WaitsToIgnore (wait_type) VALUES ('CLR_MANUAL_EVENT');
INSERT #WaitsToIgnore (wait_type) VALUES ('SP_SERVER_DIAGNOSTICS_SLEEP');
INSERT #WaitsToIgnore (wait_type) VALUES ('QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP');
INSERT #WaitsToIgnore (wait_type) VALUES ('QDS_PERSIST_TASK_MAIN_LOOP_SLEEP');
INSERT #WaitsToIgnore (wait_type) VALUES ('HADR_WORK_QUEUE');
INSERT #WaitsToIgnore (wait_type) VALUES ('BROKER_TRANSMITTER');
INSERT #WaitsToIgnore (wait_type) VALUES ('HADR_NOTIFICATION_DEQUEUE');
INSERT #WaitsToIgnore (wait_type) VALUES ('HADR_CLUSAPI_CALL');
INSERT #WaitsToIgnore (wait_type) VALUES ('HADR_TIMER_TASK');
INSERT #WaitsToIgnore (wait_type) VALUES ('HADR_LOGCAPTURE_WAIT');
INSERT #WaitsToIgnore (wait_type) VALUES ('CLR_SEMAPHORE');
INSERT #WaitsToIgnore (wait_type) VALUES ('HADR_SYNC_COMMIT');
INSERT #WaitsToIgnore (wait_type) VALUES ('REDO_THREAD_PENDING_WORK');
GO

DECLARE @MinSinceStartup INT 
SELECT @MinSinceStartup = DATEDIFF(mi, sqlserver_start_time, GETDATE()) 
	FROM sys.dm_os_sys_info 
DECLARE @SecSinceStartup BIGINT 
SET @SecSinceStartup = @MinSinceStartup*60

SELECT TOP 20 WS.wait_type, 
	SUM(WS.waiting_tasks_count) AS sum_waiting_tasks_count, 
	SUM(WS.wait_time_ms) AS sum_wait_time_ms, 
	SUM(WS.wait_time_ms*.001) AS sum_wait_time_sec, 
	--avg wait in ms 
	(SUM(WS.wait_time_ms))/(SUM(WS.waiting_tasks_count)) AS avg_wait_time_ms, 
	--time spent as % of total time is wait_time/total_time 
	(SUM(WS.wait_time_ms*.001)) / @SecSinceStartup * 100 AS percent_total_time, 
	SUM(WS.signal_wait_time_ms) AS sum_signal_wait_time_ms
FROM sys.dm_os_wait_stats WS 
	LEFT JOIN #WaitsToIgnore WTI ON WTI.wait_type = WS.wait_type 
WHERE WTI.wait_type IS NULL
GROUP BY WS.wait_type
ORDER BY SUM(WS.wait_time_ms) DESC; 

--Clean up 
DROP TABLE #WaitsToIgnore; 
