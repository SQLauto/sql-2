--Get file id from here:
--select * from sysfiles
/*
fileid groupid size        maxsize     growth      status      perf        name                                                                                                                             filename                                                                                                                                                                                                                                                             
------ ------- ----------- ----------- ----------- ----------- ----------- -------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
1      1       2800        -1          10          1081346     0           FoodMart_dat                                                                                                                     C:\SQL\MSSQL$DEV\data\FoodMart.mdf                                                                                                                                                                                                                                  
2      0       256         -1          10          1081410     0           FoodMart_log                                                                                                                     C:\SQL\MSSQL$DEV\data\FoodMart.ldf                                                                                                                                                                                                                                  
*/

--use fileid as parameter for this:
dbcc shrinkfile (2 ,truncateonly)
/*
DbId   FileId CurrentSize MinimumSize UsedPages   EstimatedPages 
------ ------ ----------- ----------- ----------- -------------- 
16     2      256         256         256         256

(1 row(s) affected)
*/