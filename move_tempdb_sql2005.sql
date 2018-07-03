/*
1. Open SQL Server Management Studio.

2. Connect to the desired server.

3. Click the New Query button.

4. Copy and paste the following into the query pane:
*/

USE master;
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev, FILENAME = '{new location}\tempdb.mdf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = templog, FILENAME = '{new location}\templog.ldf');
GO

/*
5. Change {new location} in the pasted code (for both the tempdb.mdf and templog.ldf files) to the path of the new location.

6. Click Execute.

7. Go to the Control Panel and then Administrative Tools. Select Services.

8. Stop and Start SQL Server (MSSQLSERVER).

9. Go back to SQL Server Management Studio and open a new query pane.

10. Copy and paste the following to verify that tempdb has moved to the new location:
*/

SELECT name, physical_name
FROM sys.master_files
WHERE database_id = DB_ID('tempdb');

/*

11. Click Execute.

12. In the physical_name column, you should see the path to the new location.

*/