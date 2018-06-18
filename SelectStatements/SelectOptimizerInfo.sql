USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[OptimizerInfo];

SELECT * 
FROM [hlthchk].[OptimizerInfo]
WHERE InsertDate = @maxdate;