From:	Besada, Jorge L. (CCL)
Sent:	Wednesday, August 24, 2011 4:06 PM
To:	Guda, Anand (CCL)
Subject:	goodie to find age of files in days

Save this and try it:

@echo off
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

cd /d "%temp%"

call:jdate tnow "%date%"
for %%F in (*.*) do (
    call:ftime tfile "%%F"
    set /a diff=tnow-tfile
    echo.%%~nxF is !diff! days old
)

ECHO.&PAUSE&GOTO:EOF


::-----------------------------------------------------------------------------------
::-- Functions start below here
::-----------------------------------------------------------------------------------


:ftime JD filename attr -- returns the file time in julian days
::                      -- JD    [out]    - valref file time in julian days
::                      -- attr  [in,opt] - time field to be used, creation/last-access/last-write, see 'dir /?', i.e. /tc, /ta, 
/tw, default is /tw
:$created 20060101 :$changed 20090322 :$categories DateAndTime
:$source http://www.dostips.com
SETLOCAL
set file=%~2
set attr=%~3
if not defined attr (call:jdate JD "- %~t2"
) ELSE (for /f %%a in ('"dir %attr% /-c "%file%"|findstr "^^[0-9]""') do call:jdate JD "%%a")
( ENDLOCAL & REM RETURN VALUES
    IF "%~1" NEQ "" (SET %~1=%JD%) ELSE (echo.%JD%)
)
EXIT /b


:jdate JD DateStr -- converts a date string to julian day number with respect to regional date format
::                -- JD      [out,opt] - julian days
::                -- DateStr [in,opt]  - date string, e.g. "03/31/2006" or "Fri 03/31/2006" or "31.3.2006"
:$reference 
http://groups.google.com/group/alt.msdos.batch.nt/browse_frm/thread/a0c34d593e782e94/50ed3430b
6446af8#50ed3430b6446af8
:$created 20060101 :$changed 20080219
:$source http://www.dostips.com
SETLOCAL
set DateStr=%~2&if "%~2"=="" set DateStr=%date%
for /f "skip=1 tokens=2-4 delims=(-)" %%a in ('"echo.|date"') do (
    for /f "tokens=1-3 delims=/.- " %%A in ("%DateStr:* =%") do (
        set %%a=%%A&set %%b=%%B&set %%c=%%C))
set /a "yy=10000%yy% %%10000,mm=100%mm% %% 100,dd=100%dd% %% 100"
set /a JD=dd-32075+1461*(yy+4800+(mm-14)/12)/4+367*(mm-2-(mm-14)/12*12)/12-3*((yy+4900+(mm-
14)/12)/100)/4
ENDLOCAL & IF "%~1" NEQ "" (SET %~1=%JD%) ELSE (echo.%JD%)
EXIT /b




From: Guda, Anand (CCL)  
Sent: Wednesday, August 24, 2011 3:49 PM 
To: Rodriguez, Maritza; Zalkin, Gregg (CarnCorp) 
Cc: Garcia Murray, Eugenia I; Bullen, Robert (CCL); Besada, Jorge L. (CCL); Chen, Darrell; Sloan, Mary 
(CarnCorp); Steve Rodell; Tracy Harding 
Subject: RE: Future OOCE Files

Please note that the OOCE files should be sent as .TXT files for our process to be picked up.

Thanks
Anand

From: Rodriguez, Maritza [mailto:maritza_rodriguez@uhc.com]  
Sent: Wednesday, August 24, 2011 3:10 PM 
To: Zalkin, Gregg (CarnCorp) 
Cc: Garcia Murray, Eugenia I; Guda, Anand (CCL); Bullen, Robert (CCL); Besada, Jorge L. (CCL); Chen, 
Darrell; Sloan, Mary (CarnCorp); Steve Rodell; Tracy Harding 
Subject: RE: Future OOCE Files

Yes. That should not be a problem. 
 
Please let me know if you have any other questions. 
 
Maritza 
 
 
 
Sent with Good (www.good.com) 
 
 
-----Original Message----- 
From: Zalkin, Gregg (CarnCorp) [GZalkin@carnival.com] 
Sent: Wednesday, August 24, 2011 02:04 PM Central Standard Time 
To: Rodriguez, Maritza 
Cc: Garcia Murray, Eugenia I; Guda, Anand (CCL); Bullen, Robert (CCL); Besada, Jorge L. 
(CCL); Chen, Darrell; Sloan, Mary (CarnCorp); 'Steve Rodell'; Tracy Harding 
Subject: Future OOCE Files
Maritza:

Good afternoon.  Starting today, can you start leveraging the new OOCE file transfer process by placing 
files on the United Healthcare secure FTP site for Carnival to pick up?  

Thanks,
Gregg


________________________________________
Gregg Zalkin  
Strategic Projects  
Carnival Corporation & plc 
(305) 406-6792  
gzalkin@carnival.com 



From: Zalkin, Gregg (CarnCorp)  
Sent: Monday, August 22, 2011 12:09 PM 
To: 'maritza_rodriguez@uhc.com'; 'darrell_chen@uhc.com' 
Cc: 'eugenia_g_murray@uhc.com'; Guda, Anand (CCL); Bullen, Robert (CCL); Besada, Jorge L. (CCL) 
Subject: FW: SFTP setup 
Importance: High

Darrell and Maritza:

Good afternoon.  Carnival Cruise Lines’ technology team is ready to test the file transfer of an OOCE file 
via FTP.  Can you two assist in the testing of a sample OOCE file (perhaps a prior file) – by placing the file in 
the applicable United Healthcare Secure FTP site for Carnival to pick up?  Please read the email thread 
below for details.

Can you work with Anand Guda at 305-406-5622?

Thanks for your help,
Gregg

________________________________________
Gregg Zalkin  
Strategic Projects  
Carnival Corporation & plc 
(305) 406-6792  
gzalkin@carnival.com 



From: Guda, Anand (CCL)  
Sent: Monday, August 22, 2011 11:36 AM 
To: Zalkin, Gregg (CarnCorp) 
Cc: Bullen, Robert (CCL); Besada, Jorge L. (CCL) 
Subject: FW: SFTP setup

Gregg

I have not received the sample file from UHC (refer to my Email below).  I really do not know how it looks 
like or  the content in it.  All I know it is a TXT file.  Since our development and initial testing is complete, do 
you want us to move forward with production deployment?. 

For a production deployment, I will send you  a User acceptance test (UAT) script and I need your sign off 
on this.  Once the UAT is signed off, then I can get the deployment plan to you/Bob Kirk  for sign off.

Please let us know if I can send you UAT document for sign off.


Thanks
Anand





From: Guda, Anand (CCL)  
Sent: Wednesday, August 17, 2011 4:34 PM 
To: 'Garcia Murray, Eugenia I'; Chen, Darrell; Zalkin, Gregg (CarnCorp) 
Cc: Kudlyk, Ross; Inzinna, Mark (CCL); Besada, Jorge L. (CCL); Bullen, Robert (CCL) 
Subject: RE: SFTP setup

Eugenia

Can  a sample of the OOCE file be placed in the Secure FTP site.  Since we are testing, our users can 
validate the format, presentation of data  and information in the file.  

Thanks
Anand 


From: Garcia Murray, Eugenia I [mailto:eugenia_g_murray@uhc.com]  
Sent: Wednesday, August 17, 2011 2:18 PM 
To: Chen, Darrell; Guda, Anand (CCL); Zalkin, Gregg (CarnCorp) 
Cc: Kudlyk, Ross; Inzinna, Mark (CCL); Besada, Jorge L. (CCL); Bullen, Robert (CCL) 
Subject: Re: SFTP setup

This sftp site is for the ooce file that will be sent as a txt file 
 
Act. Eugenia I Garcia Murray  
Exec. Acct Manager  
UnitedHealthcare International  
Eugenia_g_murray@uhc.com

 
From: Chen, Darrell  
To: Guda, Anand (CCL) <AGuda@carnival.com>; Zalkin, Gregg (CarnCorp) <GZalkin@carnival.com>  
Cc: Garcia Murray, Eugenia I; Kudlyk, Ross; Inzinna, Mark (CCL) <MInzinna@carnival.com>; Besada, 
Jorge L. (CCL) <JBesada@carnival.com>; Bullen, Robert (CCL) <RBullen@carnival.com>  
Sent: Wed Aug 17 13:15:30 2011 
Subject: RE: SFTP setup 
Eugenia,

Anand has confirmed that he is able to connect to the SFTP site and extract the TXT files that we put out 
there. He would like to test the connection with a sample data file that they would normally consume. Do 
you know what type of file we will be sending to them and how we can get a test file?
 
Darrell

From: Guda, Anand (CCL) [mailto:AGuda@carnival.com]  
Sent: Tuesday, August 16, 2011 3:42 PM 
To: Zalkin, Gregg (CarnCorp) 
Cc: Garcia Murray, Eugenia I; Kudlyk, Ross; Inzinna, Mark (CCL); Besada, Jorge L. (CCL); Bullen, 
Robert (CCL); Chen, Darrell 
Subject: RE: SFTP setup

All:

We received the login information and the test file.  We are able to connect to the secure Website using 
WINSCP program.  We are now working on the WINSCP scripting and test them in test server

Thanks
Anand Guda



From: Guda, Anand (CCL)  
Sent: Tuesday, August 16, 2011 10:58 AM 
To: Chen, Darrell (darrell_chen@uhc.com) 
Cc: Garcia Murray, Eugenia I (eugenia_g_murray@uhc.com); Kudlyk, Ross (ross_kudlyk@uhc.com); 
Zalkin, Gregg (CarnCorp); Inzinna, Mark (CCL); Besada, Jorge L. (CCL); Bullen, Robert (CCL) 
Subject: FW: SFTP setup

Darrell

I left you a voice mail this morning.  Based on the last discussion in July, you have requested a Public key 
 for Secure FTP program, and this has been sent to you (attached a copy of public key).  At this time, I am 
looking for login credentials to your secure FTP site and a  file be placed in the folder

1.       Create a folder called   CCL\Outbound in your FTP site
2.       Provide us with FTP link
3.       Send us the userID and  password. (you  can send a separate Email or call and let me know)

Any questions, please give me a call.

Thanks
Anand Guda
305-406-5622


From: Guda, Anand (CCL)  
Sent: Tuesday, July 26, 2011 5:32 PM 
To: Chen, Darrell 
Cc: Besada, Jorge L. (CCL); Garcia Murray, Eugenia I; Kudlyk, Ross; Zalkin, Gregg (CarnCorp); Inzinna, 
Mark (CCL) 
Subject: RE: SFTP setup

Darrell

As discussed yesterday, we are using WinSCP program

http://winscp.net/eng/index.php

and as requested by you, the public key is attached.  Please encrypt the file using this public key and place a 
test file in the FTP folder.   Once you have the file, please provide the login credentials. We will test.

Please let me know if you have questions.

Thanks
Anand Guda
305-406-5622




From: Chen, Darrell [mailto:darrell_chen@uhc.com]  
Sent: Monday, July 25, 2011 3:01 PM 
To: Guda, Anand (CCL) 
Cc: Besada, Jorge L. (CCL); Garcia Murray, Eugenia I; Kudlyk, Ross; Zalkin, Gregg (CarnCorp); Inzinna, 
Mark (CCL) 
Subject: RE: SFTP setup

We are currently moving our clients from PGP to SFTP. Could you please send us a SFTP key for this 
connection? Please let me know if you have any questions.
 
Darrell

 
From: Guda, Anand (CCL) [mailto:AGuda@carnival.com]  
Sent: Monday, July 25, 2011 10:18 AM 
To: Chen, Darrell 
Cc: Besada, Jorge L. (CCL); Garcia Murray, Eugenia I; Kudlyk, Ross; Zalkin, Gregg (CarnCorp); Inzinna, 
Mark (CCL) 
Subject: RE: SFTP setup
Darrell

Attached is the Carnival, encryption key.   Rename the extension of the file to gpg.  In order to match the 
Design of existing secure FTP program at CCL,   I need following

1.       Create a folder called   CCL\Outbound in your FTP site
2.       Provide us with FTP link
3.       Send us the userID and  password. (you  can send a separate Email or call and let me know)

Once I receive the information, we can do a quick test. 
Please let me know if you have questions.



Thanks
Anand Guda 
Application Analyst – Client Server Systems 
Carnival Cruise Lines | 3655 NW 87th Avenue | Miami, FL 33178 |  
p: 305.599.2600 Ext. 65622 | f: 305.406.5729 | e: aguda@carnival.com 

From: Chen, Darrell [mailto:darrell_chen@uhc.com]  
Sent: Monday, July 25, 2011 9:37 AM 
To: Guda, Anand (CCL); Besada, Jorge L. (CCL) 
Cc: Garcia Murray, Eugenia I; Kudlyk, Ross 
Subject: SFTP setup

You were identified as the technical contact for Carnival by Eugenia Garcia Murray. We want to start the 
process of getting a SFTP site setup for Carnival. In order to do so we need your public key information. 
 
SSH/SFTP
SFTP, or secure FTP, is a program that uses SSH to transfer files. Unlike standard FTP, it encrypts 
both commands and data, preventing passwords and sensitive information from being transmitted in the 
clear over the network. It’s functionally is similar to FTP, but because it uses a different protocol, you 
can't use a standard FTP client to talk to an SFTP server. There are two ways you can use SFTP: 
graphical SFTP clients and command-line SFTP.

Password-less authentication and SSH key exchange: Similar to PGP key exchange UHG will need 
your public key to add to our known host file.

Graphical SFTP clients (Windows users)
Using graphical SFTP clients simplifies file transfers by allowing you to transmit files by dragging and 
dropping icons between windows.

Unlike FTP, there is no software built into the Windows Operating system to support SSH/SFTP. You 
must use a third party FTP application with Windows, I.e., WS_FTP Pro by Ipswich. These applications 
are relatively inexpensive, reliable, allow for automation and can include support for other protocols like 
SFTP/SSH and may include built in PGP file encryption.

Command line SFTP (UNIX users)  http://www.openssh.com/
You can use command line SFTP from your UNIX workstation. To start an SFTP session, at the 
command prompt, enter:

sftp username@xsrprd.uhc.com 
For example, to connect to your “user1” account on the host sithlord.com, you would enter:

sftp user1@xsrprd.uhc.com

Enter your password when prompted.

Some standard commands for command line SFTP include: 

cd                    Change the directory on the remote computer  
dir (or ls)           List the files in the current directory on the remote computer  ( See above )
exit (or quit)      Close the connection to the remote computer and exit SFTP  
get                   Copy a file from the remote computer to the local computer  
help (or ?)         Get help on the use of SFTP commands  
lcd                    Change the directory on the local computer  
lls                     See a list of the files in the current directory on the local computer  
lpwd                 Show the current directory (present working directory) on the local computer  
put                   Copy a file from the local computer to the remote computer  
pwd                  Show the current directory (present working directory) on the remote computer  
version                         Display the SFTP version  
 
Regards,
Darrell Chen
Darrell Chen
Network Administrator 
Infrastructure
UnitedHealthcare International
3100 SW 145 Ave 
Miramar, FL 33026 
darrell_chen@uhc.com 
p. (954) 378-0693
 
 
 
This e-mail, including attachments, may include confidential 
and/or 
proprietary information, and may be used only by the person or 
entity 
to which it is addressed. If the reader of this e-mail is not the 
intended 
recipient or his or her authorized agent, the reader is hereby 
notified 
that any dissemination, distribution or copying of this e-mail is 
prohibited. If you have received this e-mail in error, please 
notify the 
sender by replying to this message and delete this e-mail 
immediately.
 
This e-mail, including attachments, may include confidential 
and/or 
proprietary information, and may be used only by the person or 
entity 
to which it is addressed. If the reader of this e-mail is not the 
intended 
recipient or his or her authorized agent, the reader is hereby 
notified 
that any dissemination, distribution or copying of this e-mail is 
prohibited. If you have received this e-mail in error, please 
notify the 
sender by replying to this message and delete this e-mail 
immediately.
 
This e-mail, including attachments, may include confidential 
and/or 
proprietary information, and may be used only by the person or 
entity 
to which it is addressed. If the reader of this e-mail is not the 
intended 
recipient or his or her authorized agent, the reader is hereby 
notified 
that any dissemination, distribution or copying of this e-mail is 
prohibited. If you have received this e-mail in error, please 
notify the 
sender by replying to this message and delete this e-mail 
immediately.
 
This e-mail, including attachments, may include confidential 
and/or 
proprietary information, and may be used only by the person or 
entity 
to which it is addressed. If the reader of this e-mail is not the 
intended 
recipient or his or her authorized agent, the reader is hereby 
notified 
that any dissemination, distribution or copying of this e-mail is 
prohibited. If you have received this e-mail in error, please 
notify the 
sender by replying to this message and delete this e-mail 
immediately.
