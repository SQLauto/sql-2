SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


Create  PROC dbo.usp_Repair_Orphan_Users_All_DBS
AS
-------------------------------------------------------------------------------
--  Description: This is a DBA utility used to resync all user/login sids, 
--  in all databases (unless limited)
--
--  Revision History
--  Date              Author            Revision Description
--  09/07/2005        Tduffy            Original version
-------------------------------------------------------------------------------
--  Parameters None
-------------------------------------------------------------------------------
--  Example
--  usp_Repair_Orphan_Users_All_DBS
-------------------------------------------------------------------------------

set nocount on

DECLARE @cmd varchar(4000) 

BEGIN
    Create table #Orphan_User_Tbl 
    (
        [Database_Name] sysname COLLATE Latin1_General_CI_AS, 
        [Orphaned_User] sysname COLLATE Latin1_General_CI_AS
    )

    SET NOCOUNT ON  

    DECLARE @DBName sysname, @Qry nvarchar(4000)

    SET @Qry = ''
    SET @DBName = ''

    WHILE @DBName IS NOT NULL
    BEGIN
        SET @DBName = 
                (
                    SELECT MIN(name) 
                    FROM master..sysdatabases 
                    WHERE   name NOT IN 
                        (
                         'master', 'model', 'tempdb', 'msdb', 
                         'distribution', 'pubs', 'northwind'
                        )
                        AND DATABASEPROPERTY(name, 'IsOffline') = 0 
                        AND DATABASEPROPERTY(name, 'IsSuspect') = 0 
                        AND DATABASEPROPERTY(name, 'IsInload') = 0 
                        AND DATABASEPROPERTY(name, 'IsInRecovery') = 0 
                        AND DATABASEPROPERTY(name, 'IsInStandBy') = 0 
                        AND DATABASEPROPERTY(name, 'IsReadOnly') = 0 
                        AND DATABASEPROPERTY(name, 'IsNotRecovered') = 0 
                        AND name > @DBName
                )
        
        IF @DBName IS NULL BREAK

        SET @Qry = '    SELECT ''' + @DBName + ''' AS [Database Name], 
                CAST(su.name AS sysname) COLLATE Latin1_General_CI_AS  AS [Orphaned User]
                FROM ' + QUOTENAME(@DBName) + '..sysusers su
                inner join master..sysxlogins b
                    on su.name=b.name
                where 
                    su.sid is not null 
                    and su.sid not in (0x00,0x01)
                and su.sid <> b.sid'

        INSERT INTO #Orphan_User_Tbl EXEC (@Qry)
    END

    DECLARE MC CURSOR 
    READ_ONLY 
    FOR 
        
    SELECT [Database_Name]+ '..sp_change_users_login  ''Update_One'' , ''' + Orphaned_User  +  ''',''' + Orphaned_User + ''''
    FROM #Orphan_User_Tbl 
    ORDER BY [Database_Name], [Orphaned_User]
        
    OPEN MC 
        
    FETCH NEXT FROM MC INTO @cmd 
    WHILE (@@fetch_status <> -1) 
        BEGIN 
                IF (@@fetch_status <> -2) 
                    BEGIN 
                    --Print @cmd
                    Execute (@cmd)
                    END 
        FETCH NEXT FROM MC INTO @cmd 
        END 
    
    CLOSE MC 
    DEALLOCATE MC 

    DROP Table #Orphan_User_Tbl

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


