USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[IoStats];

SELECT * 
FROM [hlthchk].[IoStats]
WHERE InsertDate = @maxdate;