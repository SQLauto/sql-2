--Scripted setup of email for any server
--Edit as needed

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

DECLARE @server varchar(100)
SET @server = CAST(@@SERVERNAME as varchar(100));


DECLARE @ProfileName VARCHAR(255)
DECLARE @AccountName VARCHAR(255)
DECLARE @SMTPAddress VARCHAR(255)
DECLARE @EmailAddress VARCHAR(128)
DECLARE @DisplayUser VARCHAR(128)
DECLARE @EmailServerName VARCHAR(128)
DECLARE @ReplyTo VARCHAR(128)
DECLARE @AccountDescription VARCHAR(128)


--------EDIT THESE VALUES AS NEEDED-----------------------
SET @ProfileName = 'DBMailProfile';
SET @AccountName = 'DBMailAccount';
SET @EmailAddress = '_sql_executive@carnival.com';
SET @EmailServerName = 'smtphost.carnival.com';
SET @DisplayUser = 'Mail From ' + @server;
SET @ReplyTo = '_sql_executive@carnival.com';
SET @AccountDescription = @server + ' Mail Account'
----------------------------------------------------------



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
@recipients=N'_sql_executive@carnival.com',
@body= 'Test Email Body', 
@subject = 'Test Email Subject',
@profile_name = 'DBMailProfile'

