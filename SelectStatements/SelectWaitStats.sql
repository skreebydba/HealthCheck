USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[WaitStats];

SELECT * 
FROM [hlthchk].[WaitStats]
WHERE InsertDate = @maxdate;