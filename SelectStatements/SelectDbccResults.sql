USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[DbccResults];

SELECT * 
FROM [hlthchk].[DbccResults]
WHERE InsertDate = @maxdate;