USE Concurrency;

DECLARE @maxdate DATETIME;

SELECT @maxdate = MAX(InsertDate)
FROM hlthchk.AgentJobs;

SELECT * 
FROM [hlthchk].[AgentJobs]
WHERE InsertDate = @maxdate;