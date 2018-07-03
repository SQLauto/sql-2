USE master
GO
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

USE msdb
GO

DECLARE @AccountName VARCHAR(255)
SET @AccountName = 'DBMailAccount';
EXECUTE msdb.dbo.sysmail_delete_account_sp
    @account_name = @AccountName ;
GO

DECLARE @ProfileName VARCHAR(255)
SET @ProfileName = 'DBMailProfile';
EXECUTE msdb.dbo.sysmail_delete_profile_sp
    @profile_name = @ProfileName;
GO



DECLARE @ProfileName VARCHAR(255)
DECLARE @AccountName VARCHAR(255)
DECLARE @SMTPAddress VARCHAR(255)
DECLARE @EmailAddress VARCHAR(128)
DECLARE @DisplayUser VARCHAR(128)
DECLARE @EmailServerName VARCHAR(128)
DECLARE @ReplyTo VARCHAR(128)
DECLARE @AccountDescription VARCHAR(128)

SET @ProfileName = 'DBMailProfile';
SET @AccountName = 'DBMailAccount';
SET @SMTPAddress = 'DBMail@smtphost.carnival.com';
SET @EmailAddress = 'DBMail@smtphost.carnival.com';

--SET @EmailServerName = 'XXexch.SHIPDOMAIN.carnival.com';
SET @EmailServerName = 'smtphost.carnival.com';
--Uncomment for testing
--SET @EmailServerName = 'smtphost.carnival.com';

SET @DisplayUser = 'Mail From DEVSQL2';
SET @ReplyTo = 'DBMail@smtphost.carnival.com';
SET @AccountDescription = 'DEVSQL2 Mail Account'



EXECUTE msdb.dbo.sysmail_add_account_sp
    
    @account_name = @AccountName,
    @email_address = @EmailAddress,
    @display_name = @DisplayUser,
    @mailserver_name = @EmailServerName,
    @replyto_address = @ReplyTo,
    @description = @AccountDescription;

EXECUTE msdb.dbo.sysmail_add_profile_sp
@profile_name = @ProfileName 

EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
@profile_name = @ProfileName,
@account_name = @AccountName,
@sequence_number = 1 ;

--uncomment for testing
EXEC msdb.dbo.sp_send_dbmail
@recipients=N'jbesada@carnival.com',
@body= 'Test Email Body', 
@subject = 'Test Email Subject',
@profile_name = 'DBMailProfile'

