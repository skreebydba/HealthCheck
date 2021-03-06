/* 
Name: DBCC_CHECKDB.sql
Purpose: List last known good DBCC CHECKDB date per database. 
Date updated: 2015/04/01 
Permissions needed to run: sysadmin 
Notes: 
	Script written by Sandesh Segu; documented at http://www.sanssql.com/2011/03/t-sql-query-to-find-date-when-was-dbcc.html
*/ 

IF OBJECT_ID('tempdb.dbo.#DBInfo') IS NOT NULL
BEGIN

	DROP TABLE #DBInfo;

END

IF OBJECT_ID('tempdb.dbo.#Value') IS NOT NULL
BEGIN

	DROP TABLE #Value;

END


CREATE TABLE #DBInfo (
       Id INT IDENTITY(1,1),
       ParentObject VARCHAR(255),
       [Object] VARCHAR(255),
       Field VARCHAR(255),
       [Value] VARCHAR(255)
)

CREATE TABLE #Value(
DatabaseName VARCHAR(255),
LastDBCCCHeckDB_RunDate VARCHAR(255)
)

EXECUTE SP_MSFOREACHDB'INSERT INTO #DBInfo Execute (''DBCC DBINFO ( ''''?'''') WITH TABLERESULTS'');
INSERT INTO #Value (DatabaseName) SELECT [Value] FROM #DBInfo WHERE Field IN (''dbi_dbname'');
UPDATE #Value SET LastDBCCCHeckDB_RunDate=(SELECT TOP 1 [Value] FROM #DBInfo WHERE Field IN (''dbi_dbccLastKnownGood'')) where LastDBCCCHeckDB_RunDate is NULL;
TRUNCATE TABLE #DBInfo';

INSERT INTO Concurrency.hlthchk.DbccResults
(DatabaseName
,LastDBCCCheckDB_RunDate)
SELECT DatabaseName,
LastDBCCCHeckDB_RunDate 
FROM #Value

