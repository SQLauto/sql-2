-- 1) Disable referential integrity 
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL' 

-- 2) Core delete/truncate 
EXEC sp_MSForEachTable ' 
    SET QUOTED_IDENTIFIER ON 
    IF ''?'' <> ''[dbo].[sysdiagrams]'' 
    BEGIN 
        IF OBJECTPROPERTY(object_id(''?''), ''TableHasForeignRef'') = 1 
             DELETE FROM ? 
        ELSE TRUNCATE TABLE ? 
        --select ''?'' as tablename, count(*) as ''count'' from ? 
        print ''?''
    END '

-- 3) Restore referential integrity 
EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL' 