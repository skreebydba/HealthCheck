USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM [hlthchk].[SysConfig];

SELECT * 
FROM [hlthchk].[SysConfig]
WHERE InsertDate = @maxdate;