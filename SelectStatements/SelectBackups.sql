USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM hlthchk.Backups;

SELECT * 
FROM [hlthchk].[Backups]
WHERE InsertDate = @maxdate;