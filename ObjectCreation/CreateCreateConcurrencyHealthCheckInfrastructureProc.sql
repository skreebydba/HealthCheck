-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frank Gill
-- Create date: 2017-11-14
-- Description:	Create Concurrency db and db objects to collect and store connection and activity data
-- =============================================
CREATE OR ALTER PROCEDURE CreateConcurrencyHealthCheckInfrastructure 
	-- Add the parameters for the stored procedure here
	@databasename SYSNAME = N'Concurrency',
	@schemaname SYSNAME = N'hlthchk',
	@datafile SYSNAME = N'C:\Data', 
	@logfile SYSNAME = N'C:\Logs',
	@noexec BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	DECLARE @sqlstr NVARCHAR(4000);
	DECLARE @usestr NVARCHAR(4000);
	SELECT @sqlstr =

'USE master;
IF DB_ID(N''' + @databasename + ''') IS NOT NULL
	BEGIN

		DROP DATABASE ' + @databasename + '

	END

CREATE DATABASE [' + @databasename + '] ON  PRIMARY 
( NAME = N''' +  + @databasename + ''', FILENAME = N''' + @datafile + @databasename + '.mdf'' , SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 51200KB )
	LOG ON 
( NAME = N''' + @databasename + '_log'', FILENAME = N''' + @datafile + @databasename + '_log.ldf'' , SIZE = 51200KB , MAXSIZE = 2048GB , FILEGROWTH = 51200KB )
--GO
IF (1 = FULLTEXTSERVICEPROPERTY(''IsFullTextInstalled''))
begin
EXEC [' + @databasename + '].[dbo].[sp_fulltext_database] @action = ''enable''
end
--GO
ALTER DATABASE  [' + @databasename + ']  SET ANSI_NULL_DEFAULT OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET ANSI_NULLS OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET ANSI_PADDING OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET ANSI_WARNINGS OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET ARITHABORT OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET AUTO_CLOSE OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET AUTO_CREATE_STATISTICS ON
--GO
ALTER DATABASE  [' + @databasename + ']  SET AUTO_SHRINK OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET AUTO_UPDATE_STATISTICS ON
--GO
ALTER DATABASE  [' + @databasename + ']  SET CURSOR_CLOSE_ON_COMMIT OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET CURSOR_DEFAULT  GLOBAL
--GO
ALTER DATABASE  [' + @databasename + ']  SET CONCAT_NULL_YIELDS_NULL OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET NUMERIC_ROUNDABORT OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET QUOTED_IDENTIFIER OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET RECURSIVE_TRIGGERS OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET  DISABLE_BROKER
--GO
ALTER DATABASE  [' + @databasename + ']  SET AUTO_UPDATE_STATISTICS_ASYNC OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET DATE_CORRELATION_OPTIMIZATION OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET TRUSTWORTHY OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET ALLOW_SNAPSHOT_ISOLATION OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET PARAMETERIZATION SIMPLE
--GO
ALTER DATABASE  [' + @databasename + ']  SET READ_COMMITTED_SNAPSHOT OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET HONOR_BROKER_PRIORITY OFF
--GO
ALTER DATABASE  [' + @databasename + ']  SET  READ_WRITE
--GO
ALTER DATABASE  [' + @databasename + ']  SET RECOVERY SIMPLE
--GO
ALTER DATABASE  [' + @databasename + ']  SET  MULTI_USER
--GO
ALTER DATABASE  [' + @databasename + ']  SET PAGE_VERIFY CHECKSUM
--GO
ALTER DATABASE  [' + @databasename + ']  SET DB_CHAINING OFF
--GO'

IF @noexec = 0
BEGIN
	
	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END

SELECT @sqlstr = --N'USE ' + @databasename + ';
--GO
N'USE ' + @databasename + N';
EXEC(''CREATE SCHEMA [' + @schemaname + N']'');
--GO';

IF @noexec = 0
BEGIN
	
	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END

SELECT @usestr = 'use ' + @databasename + ' exec sp_executesql @sqlstr';

SELECT @sqlstr = N'/****** Object:  StoredProcedure [' + @databasename + '].[' + @schemaname + '].[CollectConnectionCounts]    Script Date: 11/14/2017 17:18:57 ******/
CREATE PROCEDURE [' + @schemaname + '].[CollectConnectionCounts]
	@minutes int = 60
AS

	DECLARE @processdate DATETIME;

	SELECT @processdate = DATEADD(MINUTE, (@minutes * -1), CURRENT_TIMESTAMP);
	SELECT @processdate;
	INSERT INTO [' + @schemaname + '].ConnectionCounts
	(processdate
	,loginname
	,hostname
	,databasename
	,programname
	,connectioncount)
	SELECT @processdate,
	login_name, 
	[host_name],
	database_name,
	[program_name],
	COUNT(*) AS ConnectionCount
	FROM WhoIsActive
	WHERE [program_name] <> ''Microsoft® Windows® Operating System''
	AND collection_time > @processdate
	GROUP BY login_name, 
	[host_name],
	database_name,
	[program_name]
	ORDER BY COUNT(*) DESC;
--GO'

IF @noexec = 0
BEGIN
	
	EXEC sp_executesql  @usestr, N'@sqlstr nvarchar(4000)', @sqlstr=@sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END

SELECT @usestr = 'use ' + @databasename + ' exec sp_executesql @sqlstr';

SELECT @sqlstr = N'/****** Object:  StoredProcedure [' + @databasename + '].[' + @schemaname + '].[sp_exec_whoisactive]    Script Date: 11/14/2017 17:18:57 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
-- =============================================
-- Author:      Frank Gill - Concurrency, Inc.
-- Create date: 2017-05-09
-- Description: This procedure executes Adam Machanic''s sp_whoisactive and outputs the results
--				to the table specified in the @tablename parameter
-- Sample execution: EXEC sp_exec_whoisactive @tablename = ''DbActivity.dbo.WhoIsActive'';
-- NOTE: Code for the sp_whoisactive proc is available here - http://whoisactive.com/
-- =============================================
CREATE PROCEDURE [' + @schemaname + '].[sp_exec_whoisactive]
	@tablename SYSNAME

AS

BEGIN
 
	--Execute sp_whoisactive with @tablename set as the @destination_table parameter  
	EXEC master.dbo.sp_WhoIsActive
	@get_plans = 2, -- Gets the XML query plan. NOTE: XML is big, so monitor table size after enabling this proc.
	@get_outer_command = 1, -- Returns column sql_command, which is the block of code being executed.  sql_text contains the statment.
	@get_transaction_info = 1, -- Returns column tran_log_writes.  Column format is database name: log records written (log space consumed in kB)
	@get_avg_time = 1, -- Returns the average time a statement runs, if available.
	@find_block_leaders = 1, -- Returns column blocked_session_count.  SORT DESCENDING on this column to identify the lead blocker.
	@destination_table = @tablename; -- Output table.   
 
END
--GO'

IF @noexec = 0
BEGIN
	
	EXEC sp_executesql  @usestr, N'@sqlstr nvarchar(4000)', @sqlstr=@sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END

SELECT @sqlstr = N'USE ' + @databasename + N';

DROP TABLE IF EXISTS ' + @databasename + N'.' + @schemaname + N'.AgentJobs;

CREATE TABLE ' + @databasename + N'.' + @schemaname + N'.AgentJobs
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

DROP TABLE IF EXISTS ' + @databasename + N'.' + @schemaname + N'.Backups;

CREATE TABLE ' + @databasename + N'.' + @schemaname + N'.Backups
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DatabaseName SYSNAME
,RecoveryModel NVARCHAR(120)
,BackupType VARCHAR(15)
,BackupStartDate DATETIME
,BackupFinishDate DATETIME
,BackupTimeSeconds INT
,DaysSinceBackup INT);

DROP TABLE IF EXISTS ' + @databasename + N'.' + @schemaname + N'.BufferPoolSize;

CREATE TABLE ' + @databasename + N'.' + @schemaname + N'.BufferPoolSize
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DatabaseName NVARCHAR(256)
,CachedPagesCount BIGINT
,SizeMb BIGINT);

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.CacheSize;

CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.CacheSize
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,ObjectType VARCHAR(28)
,CountPlans INT
,CountUses BIGINT
,AvgUsage BIGINT
,TotalSizeKb INT
,TotalSizeMb INT
,AvgSizeKb INT);

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.DatabaseInfo;
CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.DatabaseInfo
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

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.DbccResults;

CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.DbccResults
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DatabaseName SYSNAME
,LastDBCCCheckDB_RunDate VARCHAR(255));

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.JobHistory;
CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.JobHistory
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

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.SysConfig
CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.SysConfig
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,[Name] NVARCHAR(70)
,ValueInUse SQL_VARIANT
,MatchingValue VARCHAR(10));

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.VlfCounts
CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.VlfCounts
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DBName SYSNAME
,VLFCOUNT INT);

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.VlfCountsByStatus
CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.VlfCountsByStatus
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,DBName SYSNAME
,[Status] INT
,VLFCountByStatus INT);

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.Logins
CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.Logins
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,RolePrincipalId INT
,RoleName SYSNAME
,MemberPrincipalId INT
,MemberName SYSNAME);

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.OptimizerInfo
CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.OptimizerInfo
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,[Counter] NVARCHAR(MAX)
,Occurrence BIGINT
,[Value] FLOAT);'

IF @noexec = 0
BEGIN

	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END

SELECT @sqlstr = 'DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.PlanCache;

CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.PlanCache
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

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.IoStats;
CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.IoStats
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

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.WaitStats;
CREATE TABLE '+ @databasename + N'.' + @schemaname + N'.WaitStats
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,WaitType NVARCHAR(120)
,SumWaitingTasksCount BIGINT
,SumWaitTimeMs BIGINT
,SumWaitTimeSec BIGINT
,AvgWaitTimeMs BIGINT
,PercentTotalTime NUMERIC
,SumSignalWaitTimeMs BIGINT);

DROP TABLE IF EXISTS '+ @databasename + N'.' + @schemaname + N'.ServerPrincipals;
CREATE TABLE '+ @databasename +N'.' + @schemaname + N'.ServerPrincipals
(RowId INT IDENTITY(1,1)
,InsertDate DATETIME DEFAULT CURRENT_TIMESTAMP
,PrincipalName SYSNAME
,[SID] VARBINARY(85)
,TypeDesc NVARCHAR(120)
,IsDisabled BIT
,DefaultDatabaseName SYSNAME);'

IF @noexec = 0
BEGIN

	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END
END


SELECT @sqlstr = N'USE [' + @databasename + ']
--GO
/****** Object:  Table [' + @schemaname + '].[WhoIsActive]    Script Date: 11/14/2017 17:18:57 ******/
SET ANSI_NULLS ON
--GO
SET QUOTED_IDENTIFIER ON
--GO
SET ANSI_PADDING ON
--GO
CREATE TABLE [' + @schemaname + '].[WhoIsActive](
	[dd hh:mm:ss.mss] [varchar](20) NULL,
	[dd hh:mm:ss.mss (avg)] [varchar](20) NULL,
	[session_id] [smallint] NULL,
	[sql_text] [xml] NULL,
	[sql_command] [xml] NULL,
	[login_name] [sysname] NOT NULL,
	[wait_info] [nvarchar](4000) NULL,
	[tran_log_writes] [nvarchar](4000) NULL,
	[CPU] [varchar](30) NULL,
	[tempdb_allocations] [varchar](30) NULL,
	[tempdb_current] [varchar](30) NULL,
	[blocking_session_id] [smallint] NULL,
	[blocked_session_count] [varchar](30) NULL,
	[reads] [varchar](30) NULL,
	[writes] [varchar](30) NULL,
	[physical_reads] [varchar](30) NULL,
	[query_plan] [xml] NULL,
	[used_memory] [varchar](30) NULL,
	[status] [varchar](30) NULL,
	[tran_start_time] [datetime] NULL,
	[open_tran_count] [varchar](30) NULL,
	[percent_complete] [varchar](30) NULL,
	[host_name] [sysname] NOT NULL,
	[database_name] [sysname] NOT NULL,
	[program_name] [sysname] NOT NULL,
	[start_time] [datetime] NULL,
	[login_time] [datetime] NULL,
	[request_id] [int] NULL,
	[collection_time] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
--GO
SET ANSI_PADDING OFF
--GO
/****** Object:  Table [' + @schemaname + '].[ConnectionCounts]    Script Date: 11/14/2017 17:18:57 ******/
SET ANSI_NULLS ON
--GO
SET QUOTED_IDENTIFIER ON
--GO
CREATE TABLE [' + @schemaname + '].[ConnectionCounts](
	[processdate] [datetime] NULL,
	[loginname] [sysname] NOT NULL,
	[hostname] [sysname] NOT NULL,
	[databasename] [sysname] NOT NULL,
	[programname] [sysname] NOT NULL,
	[connectioncount] [int] NULL
) ON [PRIMARY]
--GO'

IF @noexec = 0
BEGIN
	
	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END
