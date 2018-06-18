USE Concurrency;

DROP TABLE IF EXISTS Concurrency.hlthchk.AgentJobs;

CREATE TABLE Concurrency.hlthchk.AgentJobs
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,JobId UNIQUEIDENTIFIER
,JobName SYSNAME
,JobOwner SYSNAME
,JobCategory SYSNAME
,JobDescription NVARCHAR(1024)
,IsEnabled VARCHAR(3)
,JobCreatedOn DATETIME
,JobLastModifiedOn DATETIME
,OriginatingServerName SYSNAME
,JobStartStepNo INT
,JobStartStepName SYSNAME
,IsScheduled VARCHAR(3)
,JobScheduleID UNIQUEIDENTIFIER
,JobScheduleName SYSNAME
,JobDeletionCrtierion VARCHAR(13));

DROP TABLE IF EXISTS Concurrency.hlthchk.Backups;

CREATE TABLE Concurrency.hlthchk.Backups
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DatabaseName SYSNAME
,RecoveryModel NVARCHAR(120)
,BackupType VARCHAR(15)
,BackupStartDate DATETIME
,BackupFinishDate DATETIME
,BackupTimeSeconds INT
,DaysSinceBackup INT);

DROP TABLE IF EXISTS Concurrency.hlthchk.BufferPoolSize;

CREATE TABLE Concurrency.hlthchk.BufferPoolSize
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DatabaseName NVARCHAR(256)
,CachedPagesCount BIGINT
,SizeMb BIGINT);

DROP TABLE IF EXISTS Concurrency.hlthchk.CacheSize;

CREATE TABLE Concurrency.hlthchk.CacheSize
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,ObjectType VARCHAR(28)
,CountPlans INT
,CountUses BIGINT
,AvgUsage BIGINT
,TotalSizeKb INT
,TotalSizeMb INT
,AvgSizeKb INT);

DROP TABLE IF EXISTS Concurrency.hlthchk.DatabaseInfo;
CREATE TABLE Concurrency.hlthchk.DatabaseInfo
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DatabaseId INT
,DBName SYSNAME
,DBState NVARCHAR(120)
,RecoveryModel NVARCHAR(120)
,DataFileCount INT
,DataFileSize_MB BIGINT
,DataFileFreeSpace_MB BIGINT
,LogFileCount INT
,LogFileSize_MB BIGINT
,LogFileFreeSpace_MB BIGINT
,Log_Larger_Than_Data NVARCHAR(3)
,DBCompatLevel TINYINT
,DBCollation SYSNAME
,Page_Verify_Option_Desc NVARCHAR(120)
,SnapshotIsolation NVARCHAR(120)
,RCSI VARCHAR(3));

DROP TABLE IF EXISTS Concurrency.hlthchk.DbccResults;

CREATE TABLE Concurrency.hlthchk.DbccResults
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DatabaseName SYSNAME
,LastDBCCCheckDB_RunDate VARCHAR(255));

DROP TABLE IF EXISTS Concurrency.hlthchk.JobHistory;
CREATE TABLE Concurrency.hlthchk.JobHistory
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,ServerName SYSNAME
,JobName SYSNAME
,JobId UNIQUEIDENTIFIER
,RunStatus VARCHAR(30)
,RunDate DATE
,RunTime CHAR(5)
,RunDuration CHAR(8)
,SqlMessageId INT
,SqlSeverity INT
,Message NVARCHAR(MAX));

DROP TABLE IF EXISTS Concurrency.hlthchk.SysConfig
CREATE TABLE Concurrency.hlthchk.SysConfig
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,[Name] NVARCHAR(70)
,ValueInUse SQL_VARIANT
,MatchingValue VARCHAR(10));

DROP TABLE IF EXISTS Concurrency.hlthchk.VlfCounts
CREATE TABLE Concurrency.hlthchk.VlfCounts
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DBName SYSNAME
,VLFCOUNT INT);

DROP TABLE IF EXISTS Concurrency.hlthchk.VlfCountsByStatus
CREATE TABLE Concurrency.hlthchk.VlfCountsByStatus
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DBName SYSNAME
,[Status] INT
,VLFCountByStatus INT);

DROP TABLE IF EXISTS Concurrency.hlthchk.Logins
CREATE TABLE Concurrency.hlthchk.Logins
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,RolePrincipalId INT
,RoleName SYSNAME
,MemberPrincipalId INT
,MemberName SYSNAME);

DROP TABLE IF EXISTS Concurrency.hlthchk.OptimizerInfo
CREATE TABLE Concurrency.hlthchk.OptimizerInfo
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,[Counter] NVARCHAR(MAX)
,Occurrence BIGINT
,[Value] FLOAT);

DROP TABLE IF EXISTS Concurrency.hlthchk.PlanCache;

CREATE TABLE Concurrency.hlthchk.PlanCache
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,StatementText NVARCHAR(MAX)
,ExecutionCount BIGINT
,TotalWorkerTimeMs BIGINT
,AvgWorkerTimeMs BIGINT
,TotalLogicalReads BIGINT
,AvgLogicalReads BIGINT
,TotalElapsedTimeMs BIGINT
,AvgElapsedTimeMs BIGINT
,CreationTime DATETIME
,LastExecutionTime DATETIME
,HoursInCache INT
,DatabaseName SYSNAME NULL);

DROP TABLE IF EXISTS Concurrency.hlthchk.IoStats;
CREATE TABLE Concurrency.hlthchk.IoStats
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DatabaseName SYSNAME
,FileType NVARCHAR(6)
,PhysicalName NVARCHAR(520)
,NumOfReads BIGINT
,MbRead BIGINT
,IoStallReadMs BIGINT
,AvgReadStallMs BIGINT
,NumOfWrites BIGINT
,MbWritten BIGINT
,IoStallWriteMs BIGINT
,AvgWriteStallMs BIGINT);

DROP TABLE IF EXISTS Concurrency.hlthchk.WaitStats;
CREATE TABLE Concurrency.hlthchk.WaitStats
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,WaitType NVARCHAR(120)
,SumWaitingTasksCount BIGINT
,SumWaitTimeMs BIGINT
,SumWaitTimeSec BIGINT
,AvgWaitTimeMs BIGINT
,PercentTotalTime NUMERIC
,SumSignalWaitTimeMs BIGINT);

DROP TABLE IF EXISTS Concurrency.hlthchk.ServerPrincipals;
CREATE TABLE Concurrency.hlthchk.ServerPrincipals
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,PrincipalName SYSNAME
,[SID] VARBINARY(85)
,TypeDesc NVARCHAR(120)
,IsDisabled BIT
,DefaultDatabaseName SYSNAME);
