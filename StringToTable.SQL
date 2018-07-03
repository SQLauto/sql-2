/* Usage
    DECLARE @array VARCHAR(max)
    SET  @array = '1,2,4,8'
    SELECT item FROM strToTable(@array,',')

    Source: http://www.sqlservercentral.com/articles/CTE/67974/

*/


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Amit Gaur
-- Create date: July 25th 2008
-- Description: Convert a string to a table
-- =============================================
CREATE FUNCTION [dbo].[strToTable] 
(
    @array varchar(max),
    @del char(1)
)
RETURNS 
@listTable TABLE 
(
    item int
)
AS
BEGIN
    
    WITH rep (item,list) AS
    (
        SELECT SUBSTRING(@array,1,CHARINDEX(@del,@array,1) - 1) as item,
        SUBSTRING(@array,CHARINDEX(@del,@array,1) + 1, LEN(@array)) + @del list

        UNION ALL

        SELECT SUBSTRING(list,1,CHARINDEX(@del,list,1) - 1) as item,
        SUBSTRING(list,CHARINDEX(@del,list,1) + 1, LEN(list)) list
        FROM rep
        WHERE LEN(rep.list) > 0
    )
    INSERT INTO @listTable
    SELECT item FROM rep

    RETURN 
END

GO
