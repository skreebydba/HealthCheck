USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[CacheSize];

SELECT * 
FROM [hlthchk].[CacheSize]
WHERE InsertDate = @maxdate;