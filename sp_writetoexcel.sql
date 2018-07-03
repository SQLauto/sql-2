CREATE proc sp_write2Excel 
    (
    @fileName varchar(100),
    @NumOfColumns tinyint,
    @query    varchar(200)
    )
--Obligation : create an empty Excel file with a fixed name and place on the 
server
/*

Usage
exec sp_write2Excel 
     -- Target Excel file
           'c:\temp\NorthProducts.xls' ,             
           -- Number of columns in result          
           3,                                                  
             -- The query to be exported     
           'select convert(varchar(10),ProductId),  
            ProductName,
            Convert (varchar(20),UnitPrice) from Northwind..Products'


*/
AS
Begin
        declare @dosStmt  varchar(200)
        declare @tsqlStmt varchar(500)
        declare @colList  varchar(200)
        declare @charInd  tinyint

        set nocount on

        -- construct the  columnList A,B,C ... 
        -- until Num Of columns is reached.

        set @charInd=0
        set @colList = 'A'
        while @charInd < @NumOfColumns - 1
        begin 
          set @charInd = @charInd + 1
          set @colList = @colList + ',' + char(65 + @charInd)
        end 

        -- Create an Empty Excel file as the target 
		--file name by copying the 
		--template Empty excel File
        set @dosStmt = ' copy E:\Dev\sql\empty.xls ' + @fileName
        exec master..xp_cmdshell @dosStmt

        -- Create a "temporary" linked server to that 
		--file in order to "Export" Data
        EXEC sp_addlinkedserver 'ExcelSource', 'Jet 4.0', 
		'Microsoft.Jet.OLEDB.4.0', @fileName, NULL, 'Excel 5.0'

        -- construct a T-SQL statement that will 
		--actually export the query results
        -- to the Table in the target linked server 
        set @tsqlStmt = 'Insert ExcelSource...[ExcelTable$] ' +  
		' ( ' + @colList + ' ) '+ @query

        print @tsqlStmt

        -- execute dynamically the TSQL statement
        exec (@tsqlStmt)

        -- drop the linked server 
        EXEC sp_dropserver 'ExcelSource'
        set nocount off
End
GO
