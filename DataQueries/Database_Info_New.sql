/* 
Name: Database_Info.sql 
Purpose: List basic info about databases, including data file and log files sizes.  
Date updated: 2015/04/03 
	2015/07/10 - JB - Added "Log_Larger_Than_Data" column. 
	2015/11/13 - JB - Added "page_verify_option_desc" column. 
	2016/2/22 - JB - Added FreeSpace columns. 
	2017/5/5 - FG - Added loop logic to enable file size and free space calculations for all databases
Permissions needed to run: CREATE DATABASE/ALTER ANY DATABASE/VIEW ANY DEFINITION.
Notes: 

*/

USE master;

SET NOCOUNT ON;

DECLARE @loopcount INT = 1;
DECLARE @looplimit INT;
DECLARE @databasename SYSNAME;
DECLARE @sqlstr NVARCHAR(2000);

DROP TABLE IF EXISTS #databases;
DROP TABLE IF EXISTS #freespace;

CREATE TABLE #databases
(RowId INT IDENTITY(1,1)
,DatabaseName SYSNAME);

CREATE TABLE #freespace
(database_id INT
,FileType INT
,FileCount INT
,FileSize BIGINT
,FreeSpace BIGINT);

INSERT INTO #databases
(DatabaseName)
SELECT name FROM sys.databases;

SELECT @looplimit = @@ROWCOUNT

WHILE @loopcount <= @looplimit
BEGIN

	SELECT @databasename = databasename FROM #databases WHERE RowId = @loopcount;

	SELECT @sqlstr = CONCAT('USE ', @databasename, '
SELECT MF.database_id, 
MF.type,
COUNT(MF.file_id) AS DataFileCount, 
SUM(MF.size*8) AS DataFileSize, 
SUM((MF.size*8) - ((CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT))*8)) AS FreeSpace 
FROM sys.master_files MF
WHERE MF.database_id = DB_ID(''', @databasename, ''')
GROUP BY MF.database_id, MF.type;')

	INSERT INTO #freespace
	EXEC sp_executesql @sqlstr;

	SELECT @loopcount += 1;

END

INSERT INTO Concurrency.hlthchk.DatabaseInfo
(DatabaseId
,DBName
,DBState
,RecoveryModel
,DataFileCount
,DataFileSize_MB
,DataFileFreeSpace_MB
,LogFileCount
,LogFileSize_MB
,LogFileFreeSpace_MB
,Log_Larger_Than_Data
,DBCompatLevel
,DBCollation
,Page_Verify_Option_Desc
,SnapshotIsolation
,RCSI)	
SELECT 
	DB.database_id, 
	DB.name as DBName, 
	DB.state_desc as DBState, 
	DB.recovery_model_desc as RecoveryModel,
	Data.FileCount as DataFileCount,
	(Data.FileSize/1024) as DataFileSize_MB,
	(Data.FreeSpace/1024) as DataFileFreeSpace_MB, 
	Logs.FileCount as LogFileCount,
	(Logs.FileSize/1024) AS LogFileSize_MB, 
	(Logs.FreeSpace/1024) AS LogFileFreeSpace_MB, 
	CASE WHEN Logs.FileSize > Data.FileSize THEN 'Yes' 
		ELSE '' END AS Log_Larger_Than_Data, 
	DB.compatibility_level as DBCompatLevel, 
	DB.collation_name as DBCollation, 
	DB.page_verify_option_desc, 
	DB.snapshot_isolation_state_desc as SnapshotIsolation, 
	CASE 
		WHEN DB.is_read_committed_snapshot_on = 1 THEN 'ON' 
		ELSE 'OFF' 
	END as RCSI
FROM sys.databases DB
LEFT OUTER JOIN #freespace Data
ON Data.database_id = DB.database_id
AND Data.FileType = 0
LEFT OUTER JOIN #freespace Logs
ON Logs.database_id = DB.database_id
AND Logs.FileType = 1
ORDER BY name; 
