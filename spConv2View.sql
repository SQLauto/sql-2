--Source: http://www.sqlservercentral.com/articles/T-SQL/68233/

/*
use master
go
exec sp_configure 'allow updates',1
go
reconfigure with override
go
exec sp_configure 'Ad Hoc Distributed Queries',1
go
reconfigure  with override
*/

--example:
--exec sp_ConvProc2View @procName = 'sp_who',   @viewName ='v$Session'


Create procedure sp_ConvProc2View
       ( @procName varchar(80),  @viewName varchar(80))
 as
 -- -------------------------------------------------------------
 -- Procedure name: sp_ConvProc2View
 -- Sp Author : Eli Leiba
 -- Date 08-2009
 -- Description : created a view with same result as the sp
 --  the view can be used in a SELECT statement
 -- ------------------------------------------------------------
 begin
   declare @TSQLStmt varchar(500)
   set nocount off
   -- create the CREATE VIEW tSQL statement.
   -- An OPENROWSET operator is used on the local server
   -- (. means the local SQL server )
   -- using SQLOLEDB provider along with a trusted connection
   -- (windows authentication)
   --  SET FMTONLY off ensures that the results will be output
   -- (not just the metaData)
   -- the EXEC storedProcedure finishes the OPENROWSET parameter.
   --Added by JB next two lines
   set @TSQLStmt = 'DROP VIEW ' + @viewName
   exec (@TSQLStmt)
   set @TSQLStmt = 'CREATE VIEW ' + @viewName + ' AS SELECT * FROM '  +
     'OPENROWSET ( '+ '''' +'SQLOLEDB' + ''''+ ','  +
     '''' + 'SERVER=.;Trusted_Connection=yes'+ '''' +',' +
     '''' + 'SET FMTONLY OFF EXEC ' + @procName + ''''+ ')'
   -- now , we dynamically execute the statement
   exec (@TSQLStmt)
   set nocount on
 end
go
