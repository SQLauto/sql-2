All:

Using DB_id(<db_name>) function and the IF predicate allows for this.

 

Below is a template for executing an SQL statement in ALL USER databases:

EXEC sp_msforeachdb 'USE ?; IF DB_id(''?'')>4 BEGIN <multiple SQL statements> END;'

 

Below is a template for executing an SQL statement in ALL SYSTEM databases:

EXEC sp_msforeachdb 'USE ?; IF DB_id(''?'')<=4 BEGIN <multiple SQL statements> END;'

 

This is a verification script (lists all db_names and database_ids for all used dbs on a server):

EXEC sp_msforeachdb 'USE ?; IF DB_id(''?'')>4 BEGIN PRINT DB_NAME()select DB_id(''?'') END;'

