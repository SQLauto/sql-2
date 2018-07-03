SELECT
	bus.database_name Org_DBName,
	Restored_To_DBName,
	Last_Date_Restored
FROM
	msdb..backupset bus
INNER JOIN
(
	SELECT
		backup_set_id,
		Restored_To_DBName,
		Last_Date_Restored
	FROM
		msdb..restorehistory
	INNER JOIN
	(
		SELECT 
			rh.destination_database_name Restored_To_DBName,
			Max(rh.restore_date) Last_Date_Restored
		FROM 
			msdb..restorehistory rh
		GROUP BY
			rh.destination_database_name
	) AS InnerRest
	ON
		destination_database_name = Restored_To_DBName AND
		restore_date = Last_Date_Restored
) As RestData
ON
	bus.backup_set_id = RestData.backup_set_id