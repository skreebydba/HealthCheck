USE master;

/* Code from https://blogs.technet.microsoft.com/sqlman/2009/07/19/tsql-script-determining-default-database-file-log-path/ */

IF EXISTS(SELECT 1 FROM [master].[sys].[databases] WHERE [name] = 'zzTempDBForDefaultPath')  

BEGIN  
    DROP DATABASE zzTempDBForDefaultPath   
END;

-- Create temp database. Because no options are given, the default data and --- log path locations are used

CREATE DATABASE zzTempDBForDefaultPath;

--Declare variables for creating temp database  

DECLARE @Default_Data_Path VARCHAR(512),   
        @Default_Log_Path VARCHAR(512);

--Get the default data path  

SELECT @Default_Data_Path =    
(   SELECT LEFT(physical_name,LEN(physical_name)-CHARINDEX('\',REVERSE(physical_name))+1) 
    FROM sys.master_files mf   
    INNER JOIN sys.[databases] d   
    ON mf.[database_id] = d.[database_id]   
    WHERE d.[name] = 'zzTempDBForDefaultPath' AND type = 0);

--Get the default Log path  

SELECT @Default_Log_Path =    
(   SELECT LEFT(physical_name,LEN(physical_name)-CHARINDEX('\',REVERSE(physical_name))+1)   
    FROM sys.master_files mf   
    INNER JOIN sys.[databases] d   
    ON mf.[database_id] = d.[database_id]   
    WHERE d.[name] = 'zzTempDBForDefaultPath' AND type = 1);

--Clean up. Drop de temp database

IF EXISTS(SELECT 1 FROM [master].[sys].[databases] WHERE [name] = 'zzTempDBForDefaultPath')   
BEGIN  
    DROP DATABASE zzTempDBForDefaultPath   
END;

EXEC CreateConcurrencyHealthCheckInfrastructure 
@databasename = N'Concurrency', 
@schemaname = N'hlthchk', 
@datafile = @Default_Data_Path, 
@logfile = @Default_Log_Path,
@noexec = 0;