/* 
Name: Virtual_IO_File_Stats.sql
Purpose: Physical read and write I/O since last server startup. 
Date updated: 2015/04/02 
Permissions needed to run: VIEW SERVER STATE, CREATE DATABASE/ALTER ANY DATABASE/VIEW ANY DEFINITION  
Notes: 
	Adapted from Performance Tuning with SQL Server Dynamic Management Views - http://www.red-gate.com/community/books/dynamic-management-views 

	Run "I/O since last server startup" all at once. 
		You can choose your WHERE clause and ORDER BY clause by un-commenting lines. 
	Run "Currently happening IO" all at once. 
 */

SET ARITHIGNORE ON;
GO 
SET ARITHABORT OFF;
GO

/* I/O since last server startup */ 
SELECT DB_NAME(mf.database_id) AS databaseName, mf.physical_name, divfs.num_of_reads, divfs.num_of_bytes_read, divfs.io_stall_read_ms, divfs.num_of_writes, divfs.num_of_bytes_written, divfs.io_stall_write_ms, divfs.io_stall, size_on_disk_bytes, GETDATE() AS baselineDate 
INTO #baseline 
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs 
	JOIN sys.master_files AS mf ON mf.database_id = divfs.database_id AND mf.file_id = divfs.file_id 

SELECT databaseName, 
	RIGHT(physical_name, 3) AS file_type, 
	physical_name, 
	num_of_reads, 
	(num_of_bytes_read/1024) AS mb_read, 
	io_stall_read_ms, 
	CASE WHEN num_of_reads = 0 THEN 0 
		ELSE (io_stall_read_ms/num_of_reads) 
		END AS avg_read_stall_ms, 
	num_of_writes, 
	(num_of_bytes_written/1024) AS mb_written, 
	io_stall_write_ms, 
	CASE WHEN num_of_writes = 0 THEN 0 
		ELSE (io_stall_write_ms/num_of_writes) 
		END AS avg_write_stall_ms 
FROM #baseline 
--WHERE databaseName = 'DatabaseName'
ORDER BY 
	--avg_read_stall_ms DESC
	avg_write_stall_ms DESC

DROP TABLE #baseline 

SET ARITHIGNORE OFF;
GO 
SET ARITHABORT ON;
GO




