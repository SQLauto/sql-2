SELECT 
   GETDATE() AS UnconvertedDateTime,
   CAST(GETDATE() AS nvarchar(30)) AS UsingCast,
   CONVERT(nvarchar(30), GETDATE(), 126) AS UsingConvertTo_ISO8601, 
   LEFT(CONVERT(varchar(30), GETDATE(), 120), 16) AS UsingConvertTo_ODBC_Canonical  
   
   
GO
