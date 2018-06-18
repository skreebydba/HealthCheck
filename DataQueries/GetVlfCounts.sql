USE master
GO

IF OBJECT_ID('tempdb.dbo.#VLF') IS NOT NULL
BEGIN

	DROP TABLE #VLF

END


CREATE TABLE #VLF
	(
	ServerName SYSNAME NULL DEFAULT @@servername,
	DBName SYSNAME NULL DEFAULT DB_NAME(),
	RecoveryUnitID INT,
	FileId INT NOT NULL,
	FileSize BIGINT,
	StartOffset BIGINT,
	FSeqNo INT,
	Status INT,
	Parity INT,
	CreateLSN NUMERIC(25,0)--,
	)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'i1_VLF')
CREATE CLUSTERED INDEX i1_VLF ON #VLF (DBName)
GO


EXEC sp_msforeachdb 'USE ? INSERT #VLF (RecoveryUnitID, FileId, FileSize, StartOffset, FSeqNo, Status, Parity, CreateLSN) EXEC (''DBCC LOGINFO()'')'

INSERT INTO Concurrency.hlthchk.VlfCounts
(DBName
,VlfCount)
SELECT DBName, COUNT(*) AS VLFCount
FROM #VLF
GROUP BY DBName
ORDER BY COUNT(*) DESC;

INSERT INTO Concurrency.hlthchk.VlfCountsByStatus
(DBName
,Status
,VLFCountByStatus)
SELECT DBName, [Status], COUNT(*) AS VLFCountByStatus
FROM #VLF
GROUP BY DBName, [Status]
ORDER BY DBName, [Status];

