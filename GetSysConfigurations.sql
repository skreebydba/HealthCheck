USE master;

INSERT INTO Concurrency.hlthchk.SysConfig
(Name
,ValueInUse
,MatchingValue)
SELECT [name], 
value_in_use,  
CASE
	WHEN [value] <> value_in_use THEN 'Run Config'
	ELSE 'Matching'
END AS [MatchingValue] 
FROM 
sys.configurations
ORDER BY [name];