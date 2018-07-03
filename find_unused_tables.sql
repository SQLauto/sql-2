DECLARE @tbl TABLE(id INT IDENTITY(1,1), tblname VARCHAR(128), 
found_flag CHAR(1)) 
DECLARE @cnt int 
DECLARE @loop int 
DECLARE @parm varchar(255) 


/* 
 *load variable with tables that aren't in sysdepends 
*/ 
INSERT INTO @tbl (tblname, found_flag) 
SELECT 
    OBJECT_NAME(a.id),'N' 
FROM 
    sysobjects a LEFT JOIN sysdepends b ON a.id=depid 
WHERE 
    a.type='u' AND b.depid IS NULL 
ORDER BY object_name(a.id) 


/* 
 *setup variables for the loop 
*/ 
SELECT @cnt=MAX(id) FROM @tbl 
SET @loop=1 


/* 
 *take list of tables with no dependencies  and look for job steps 
that might reference them. 
*/ 
WHILE @loop <=@cnt BEGIN 


SELECT @parm=tblname FROM @tbl WHERE id=@loop 


IF EXISTS (SELECT job_id FROM msdb..sysjobsteps WHERE 
CHARINDEX(@parm,command)>0) 
 BEGIN 
  UPDATE @tbl SET found_flag='Y' where id=@loop 
 END 
SET @loop=@loop+1 
END 


/* 
 *return table names not used in job steps or having object 
dependencies 
*/ 
SELECT tblname FROM @tbl WHERE found_flag='N' 


