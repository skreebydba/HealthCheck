USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[PlanCache];

SELECT * 
FROM [hlthchk].[PlanCache]
WHERE InsertDate = @maxdate;