USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[DatabaseInfo];

SELECT * 
FROM [hlthchk].[DatabaseInfo]
WHERE InsertDate = @maxdate;