--ALTER FUNCTION [dbo].[SplitVar]
declare @String VARCHAR(MAX)
declare @Delimiter VARCHAR(5)
set @String = '_cluster                 _dnsupdates              _entadmin                '
set @Delimiter = ' '


DECLARE @auxString	VARCHAR(MAX)
SET @auxString = REPLACE(@String, @Delimiter,'.');
WITH Split(stpos,endpos)
AS(
SELECT 0 AS stpos, CHARINDEX('.',@auxString) AS endpos
UNION ALL
SELECT CAST(endpos AS INT)+1, CHARINDEX('.',@auxString,endpos+1)
FROM Split
WHERE endpos > 0
)
SELECT SUBSTRING(@auxString,stpos,COALESCE(NULLIF(endpos,0),LEN(@auxString)+1)-stpos) 
FROM Split
WHERE SUBSTRING(@auxString,stpos,COALESCE(NULLIF(endpos,0),LEN(@auxString)+1)-stpos) > ''
