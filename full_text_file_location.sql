/*
from
http://www.sqlservercentral.com/Forums/Topic700260-146-1.aspx

Ten Centuries

Ten CenturiesTen CenturiesTen CenturiesTen CenturiesTen CenturiesTen CenturiesTen CenturiesTen Centuries

Group: General Forum Members
Last Login: 9/18/2009 3:21 AM
Points: 1,235, Visits: 6,124
    
Did you performed the below mentioned step:

Allow system table updates by using the system stored procedure sp_configure and RECONFIGURE with override, and then update the [database_name].dbo.sysfulltextcatalogs path column to the new local drive or path destination for the full-text catalog default folder, such as d:\FTData.

Please check "To move or copy full-text catalogs between local drives or paths on the same computer that is running SQL Server" section at http://support.microsoft.com/kb/240867 .

MJ
*/

/* Samples 
this script describes the steps neccessary to implement full text indexing in TSQL on your SQL SERVER system
Can be used programatically in tsql code

--Implementing Full Text Search with T-SQL stored Procedures / Eli Leiba

Enabeling Full Text search in T-SQL is usually not so "popular" as doing it with the EnterPrise Manager

So Here are the T-SQL steps you have to do in order to implement FTS in T-SQL

--1 Enabling full text on the database
EXEC sp_fulltext_database  'enable' 

--2 Create the Catalog (if does not exist)
EXEC sp_fulltext_catalog   'MyCatalog','create'  

--3 add a full text index on a Table
EXEC sp_fulltext_table     'Products', 'create', 'MyCatalog', 'pk_products'
EXEC sp_fulltext_table     'Categories', 'create', 'MyCatalog', 'pk_categories'

--4 add a column to the full text Index
EXEC sp_fulltext_column    'Products', 'ProductName', 'add' 
EXEC sp_fulltext_column    'Categories', 'Description', 'add' 

--5 activate the index
EXEC sp_fulltext_table     'Products','activate'
EXEC sp_fulltext_table     'Categories','activate'

--6 start full population
EXEC sp_fulltext_catalog   'MyCatalog', 'start_full' 

-- usage in T-SQL (CONTAINS and FREETEXT predicates)
-- Using the index in T-SQL 
USE Northwind
GO
SELECT ProductId, ProductName, UnitPrice
FROM Products
WHERE CONTAINS(  
                                   ProductName, ' "sasquatch " OR "stout" '
                                )
GO

USE Northwind
GO
SELECT CategoryName
FROM Categories
FREETEXT (
                    Description, 'sweetest candy bread and dry meat'
                   )
GO




*/