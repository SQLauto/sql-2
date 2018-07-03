EXEC msdb.dbo.sp_send_dbmail
@recipients=N'jbesada@carnival.com;ALoewenthal@carnival.com',
@body= 'email sent from ecomuatsql1',
@subject = 'Arthur is a bad boy, Meena is a good girl',
@profile_name = 'DBMailProfile'