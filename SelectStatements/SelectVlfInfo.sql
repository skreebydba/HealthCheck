USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM hlthchk.VlfCounts;

SELECT * 
FROM [hlthchk].[VlfCounts]
WHERE InsertDate = @maxdate;

SELECT @maxdate = MAX(InsertDate)
FROM hlthchk.VlfCountsByStatus;

SELECT * 
FROM [hlthchk].[VlfCountsByStatus]
WHERE InsertDate = @maxdate;