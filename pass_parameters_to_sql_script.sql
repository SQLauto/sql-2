--Use the -v switch to pass in variables.

--sqlcmd -v varMDF="C:\dev\SAMPLE.mdf" varLDF="C:\dev\SAMPLE_log.ldf"
--Then in your script file

CREATE DATABASE [SAMPLE] ON  PRIMARY 
( NAME = N'SAMPLE', FILENAME = N'$(varMDF)' , SIZE = 23552KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'SAMPLE_log', FILENAME = N'$(varLDF)' , SIZE = 29504KB , MAXSIZE = 2048GB , FILEGROWTH = 1024KB )