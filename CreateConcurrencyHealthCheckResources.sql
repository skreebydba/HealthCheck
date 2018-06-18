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
CREATE OR ALTER PROCEDURE CreateConcurrencyHealthCheckDatabase
	-- Add the parameters for the stored procedure here
	@databasename SYSNAME = N'Concurrency',
	@datafile SYSNAME = N'C:\Data\', 
	@logfile SYSNAME = N'C:\Log\',
	@noexec BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	DECLARE @sqlstr NVARCHAR(4000);
	SELECT @sqlstr =

N'USE master;
IF DB_ID(N''' + @databasename + N''') IS NOT NULL
	BEGIN

		DROP DATABASE ' + @databasename + N'

	END

CREATE DATABASE [' + @databasename + N'] ON  PRIMARY 
( NAME = N''' +  + @databasename + N''', FILENAME = N''' + @datafile + @databasename + N'.mdf'' , SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 51200KB )
	LOG ON 
( NAME = N''' + @databasename + N'_log'', FILENAME = N''' + @logfile + @databasename + N'_log.ldf'' , SIZE = 51200KB , MAXSIZE = 2048GB , FILEGROWTH = 51200KB )

IF (1 = FULLTEXTSERVICEPROPERTY(''IsFullTextInstalled''))
BEGIN
EXEC [' + @databasename + N'].[dbo].[sp_fulltext_database] @action = ''enable''
END

ALTER DATABASE  [' + @databasename + N']  SET ANSI_NULL_DEFAULT OFF

ALTER DATABASE  [' + @databasename + N']  SET ANSI_NULLS OFF

ALTER DATABASE  [' + @databasename + N']  SET ANSI_PADDING OFF

ALTER DATABASE  [' + @databasename + N']  SET ANSI_WARNINGS OFF

ALTER DATABASE  [' + @databasename + N']  SET ARITHABORT OFF

ALTER DATABASE  [' + @databasename + N']  SET AUTO_CLOSE OFF

ALTER DATABASE  [' + @databasename + N']  SET AUTO_CREATE_STATISTICS ON

ALTER DATABASE  [' + @databasename + N']  SET AUTO_SHRINK OFF

ALTER DATABASE  [' + @databasename + N']  SET AUTO_UPDATE_STATISTICS ON

ALTER DATABASE  [' + @databasename + N']  SET CURSOR_CLOSE_ON_COMMIT OFF

ALTER DATABASE  [' + @databasename + N']  SET CURSOR_DEFAULT  GLOBAL

ALTER DATABASE  [' + @databasename + N']  SET CONCAT_NULL_YIELDS_NULL OFF

ALTER DATABASE  [' + @databasename + N']  SET NUMERIC_ROUNDABORT OFF

ALTER DATABASE  [' + @databasename + N']  SET QUOTED_IDENTIFIER OFF

ALTER DATABASE  [' + @databasename + N']  SET RECURSIVE_TRIGGERS OFF

ALTER DATABASE  [' + @databasename + N']  SET  DISABLE_BROKER

ALTER DATABASE  [' + @databasename + N']  SET AUTO_UPDATE_STATISTICS_ASYNC OFF

ALTER DATABASE  [' + @databasename + N']  SET DATE_CORRELATION_OPTIMIZATION OFF

ALTER DATABASE  [' + @databasename + N']  SET TRUSTWORTHY OFF

ALTER DATABASE  [' + @databasename + N']  SET ALLOW_SNAPSHOT_ISOLATION OFF

ALTER DATABASE  [' + @databasename + N']  SET PARAMETERIZATION SIMPLE

ALTER DATABASE  [' + @databasename + N']  SET READ_COMMITTED_SNAPSHOT OFF

ALTER DATABASE  [' + @databasename + N']  SET HONOR_BROKER_PRIORITY OFF

ALTER DATABASE  [' + @databasename + N']  SET  READ_WRITE

ALTER DATABASE  [' + @databasename + N']  SET RECOVERY SIMPLE

ALTER DATABASE  [' + @databasename + N']  SET  MULTI_USER

ALTER DATABASE  [' + @databasename + N']  SET PAGE_VERIFY CHECKSUM

ALTER DATABASE  [' + @databasename + N']  SET DB_CHAINING OFF
'

IF @noexec = 0
BEGIN
	
	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END
END
GO
CREATE OR ALTER PROCEDURE CreateConcurrencyHealthCheckSchema
	-- Add the parameters for the stored procedure here
	@databasename SYSNAME = N'Concurrency',
	@schemaname SYSNAME = N'hlthchk',
	@noexec BIT = 1
AS
BEGIN

DECLARE @sqlstr NVARCHAR(4000);

SELECT @sqlstr = --N'USE ' + @databasename + ';

N'USE ' + @databasename + N';
EXEC(''CREATE SCHEMA [' + @schemaname + N']'');
';

IF @noexec = 0
BEGIN
	
	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END
END
GO

CREATE OR ALTER PROCEDURE CreateConcurrencyHealthCheckTables
	-- Add the parameters for the stored procedure here
	@databasename SYSNAME = N'Concurrency',
	@schemaname SYSNAME = N'hlthchk',
	@noexec BIT = 1
AS
BEGIN

DECLARE @sqlstr NVARCHAR(4000);

SELECT @sqlstr = N'USE [' + @databasename + N']

/****** Object:  Table [' + @schemaname + N'].[WhoIsActive]    Script Date: 11/14/2017 17:18:57 ******/
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

SET ANSI_PADDING ON

CREATE TABLE [' + @schemaname + N'].[WhoIsActive](
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

SET ANSI_PADDING OFF

/****** Object:  Table [' + @schemaname + N'].[ConnectionCounts]    Script Date: 11/14/2017 17:18:57 ******/
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

CREATE TABLE [' + @schemaname + N'].[ConnectionCounts](
	[processdate] [datetime] NULL,
	[loginname] [sysname] NOT NULL,
	[hostname] [sysname] NOT NULL,
	[databasename] [sysname] NOT NULL,
	[programname] [sysname] NOT NULL,
	[connectioncount] [int] NULL
) ON [PRIMARY]
'

IF @noexec = 0
BEGIN
	
	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END
END
GO

CREATE OR ALTER PROCEDURE CreateConcurrencyHealthCheckConnCntProc
	-- Add the parameters for the stored procedure here
	@databasename SYSNAME = N'Concurrency',
	@schemaname SYSNAME = N'hlthchk',
	@noexec BIT = 1
AS
BEGIN

DECLARE @sqlstr NVARCHAR(4000);

SELECT @sqlstr = N'USE ' + @databasename + N'
/****** Object:  StoredProcedure [' + @schemaname + N'].[CollectConnectionCounts]    Script Date: 11/14/2017 17:18:57 ******/
USE ' + @databasename + N'
EXEC(''CREATE PROCEDURE [' + @schemaname + '].[CollectConnectionCounts]
	@minutes int = 60
AS

	DECLARE @processdate DATETIME;

	SELECT @processdate = DATEADD(MINUTE, (@minutes * -1), CURRENT_TIMESTAMP);
	SELECT @processdate;
	INSERT INTO [' + @schemaname + N'].ConnectionCounts
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
	WHERE [program_name] <> ''''Microsoft® Windows® Operating System''''
	AND collection_time > @processdate
	GROUP BY login_name, 
	[host_name],
	database_name,
	[program_name]
	ORDER BY COUNT(*) DESC;'')'


IF @noexec = 0
BEGIN
	
	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END
END
GO

CREATE OR ALTER PROCEDURE CreateConcurrencyHealthCheckWhoIsActiveProc
	-- Add the parameters for the stored procedure here
	@databasename SYSNAME = N'Concurrency',
	@schemaname SYSNAME = N'hlthchk',
	@noexec BIT = 1
AS
BEGIN

DECLARE @sqlstr NVARCHAR(4000);

SELECT @sqlstr = N'USE ' + @databasename + N'
EXEC(''/****** Object:  StoredProcedure [' + @schemaname + N'].[sp_exec_whoisactive]    Script Date: 11/14/2017 17:18:57 ******/
-- =============================================
-- Author:      Frank Gill - Concurrency, Inc.
-- Create date: 2017-05-09
-- Description: This procedure executes Adam Machanic''''s sp_whoisactive and outputs the results
--				to the table specified in the @tablename parameter
-- NOTE: Code for the sp_whoisactive proc is available here - http://whoisactive.com/
-- =============================================
CREATE PROCEDURE [' + @schemaname + N'].[sp_exec_whoisactive]
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
 
END'')'


IF @noexec = 0
BEGIN
	
	EXEC sp_executesql @sqlstr;

END
ELSE
BEGIN

	PRINT @sqlstr;

END
END
GO
