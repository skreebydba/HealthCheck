USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[ServerPrincipals];

SELECT * 
FROM [hlthchk].[ServerPrincipals]
WHERE InsertDate = @maxdate;