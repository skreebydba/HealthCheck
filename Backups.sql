/* 
Name: Backups.sql 
Purpose: List most recent backup of each database. 
Date updated: 2015/04/01 
Permissions needed to run: ALTER ANY DATABASE or VIEW ANY DATABASE 
Notes: 
	If no backup has been taken, this will also be noted. 
	Data is retained since msdb..backupset was last cleaned.

Modification date: 2016/01/06 
Modified by: Jes Borland 
Modification: added DB.recovery_model_desc and T.RecoveryModel 
*/

SELECT t.name AS database_name, 
	t.RecoveryModel, 
	t.backup_type, 
	t.backup_start_date, 
	t.backup_finish_date, 
	t.backup_time_seconds,
	t.days_since_backup
FROM
(
	SELECT 
	BUS.server_name, 
	DB.name, 
	DB.recovery_model_desc as RecoveryModel,
	BUS.backup_start_date, 
	BUS.backup_finish_date, 
	DATEDIFF(ss, BUS.backup_start_date, BUS.backup_finish_date) AS backup_time_seconds, 
	DATEDIFF(DAY,BUS.backup_finish_date,CURRENT_TIMESTAMP) AS days_since_backup,
	((BUS.backup_size/1024)/1024) AS backup_size_MB, 
	CASE WHEN BUS.type = 'D' THEN 'Full' WHEN BUS.type = 'I' THEN 'Differential' WHEN BUS.type = 'L' THEN 'Log' WHEN BUS.type = 'F' THEN 'File/Filegroup' WHEN BUS.type IS NULL THEN 'No Backup Taken' ELSE 'Other' END AS backup_type,
	row_number() OVER (PARTITION BY DB.name, BUS.type ORDER BY BUS.backup_finish_date DESC) AS rw
	FROM sys.databases DB  
		LEFT OUTER JOIN  msdb..backupset BUS ON DB.name = BUS.database_name
	WHERE DB.database_id <> 2
)t
WHERE t.rw = 1;