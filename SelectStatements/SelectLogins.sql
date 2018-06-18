USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[Logins];

SELECT * 
FROM [hlthchk].[Logins]
WHERE InsertDate = @maxdate;