/*
hi as of now when i convert from acess to sql, for some reason all the bit columns in access are not converted to sql to allow null, so i have to go into each and every table to do it manually or create an alter table alter column for each and every table and each and every column,most of the columns that have bit as the datatype are named as "IsActive".

So i was wondering if there is way we can convert all the bit columns in a database to allow null with a single alter statement, 

I have looked around but cannot find an answer 

thanks 
 26   
Quote 
GSquared	Posted 9 years ago #794638
GSquared SSC Guru
SSC Guru (196K reputation)SSC Guru (196K reputation)SSC Guru (196K reputation)SSC Guru (196K reputation)SSC Guru (196K reputation)SSC Guru (196K reputation)SSC Guru (196K reputation)SSC Guru (196K reputation)
Group: General Forum Members
Points: 196372 Visits: 9733
There isn't a single statement for it, but you could write a script that would do it all at once.

Would look something like this:
*/

select 
'alter table ' + 
   (select name
   from sys.schemas
   where schema_id =
      (select schema_id
      from sys.tables
      where object_id = columns.object_id)) + '.' + 
   (select name
   from sys.tables
   where object_id = columns.object_id) +
' alter column ' + name + ' bit null;'
from sys.columns
where system_type_id = 104
and object_id in
   (select object_id
   from sys.tables)
and is_nullable = 0;

/*
Copy and paste the results from that into a window in Management Studio and run it on your test/dev database. 

- Gus "GSquared", RSVP, OODA, MAP, NMVP, FAQ, SAT, SQL, DNA, RNA, UOI, IOU, AM, PM, AD, BC, BCE, USA, UN, CF, ROFL, LOL, ETC
Property of The Thread

"Nobody knows the age of the human race, but everyone agrees it's old enough to know better." - Anon
*/