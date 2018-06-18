USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[JobHistory];

SELECT * 
FROM [hlthchk].[JobHistory]
WHERE InsertDate = @maxdate;