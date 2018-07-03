/*
SQL SERVER  Query to Find Seed Values, Increment Values and Current Identity Column value of the table

Following script will return all the tables which has identity column. It will also return the Seed Values, Increment Values and Current Identity Column value of the table.

*/
SELECT IDENT_SEED(TABLE_NAME) AS Seed,
IDENT_INCR(TABLE_NAME) AS Increment,
IDENT_CURRENT(TABLE_NAME) AS Current_Identity,
TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE OBJECTPROPERTY(OBJECT_ID(TABLE_NAME), 'TableHasIdentity') = 1
AND TABLE_TYPE = 'BASE TABLE'

--Reference : Pinal Dave (http://blog.SQLAuthority.com)