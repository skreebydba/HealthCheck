USE master;

INSERT INTO Concurrency.dbo.SysConfig
([name]
,ValueInUse
,MatchingValue)
SELECT [name], 
value_in_use,  
CASE
	WHEN [value] <> value_in_use THEN 'Run Config'
	ELSE 'Matching'
END AS [Matching Values] 
FROM 
sys.configurations
ORDER BY [name];