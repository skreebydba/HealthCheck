USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[BufferPoolSize];

SELECT * 
FROM [hlthchk].[BufferPoolSize]
WHERE InsertDate = @maxdate;