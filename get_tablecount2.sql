select distinct 'TableName'=convert(varchar(100),o.name), max(i.rows) as 'RecCount'

from sysindexes i
, sysobjects o
, master.dbo.syslogins l 
 where i.id = o.id
   and o.type = 'U'
 --  and o.uid = l.suid 
--and o.uid = l.sid 

group by 
--l.name, 
o.name

having max(i.rows) > 0

order by 1
--having RecCount > 0