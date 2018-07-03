EXEC sp_MSforeachtable @command1="ALTER TABLE ? NOCHECK CONSTRAINT ALL"
GO
You may also want to do this:

EXEC sp_MSforeachtable @command1="ALTER TABLE ? DISABLE TRIGGER ALL"
GO
To enable them afterwards

EXEC sp_MSforeachtable @command1="ALTER TABLE ? ENABLE TRIGGER ALL"
GO

-- SQL enable all constraints - enable all constraints sql server
-- sp_MSforeachtable is an undocumented system stored procedure
EXEC sp_MSforeachtable @command1="ALTER TABLE ? CHECK CONSTRAINT ALL"
GO