--select * from syscolumns where name = 'article_id_ref'
declare @fieldname varchar(100)
--select @fieldname = 'English Category Name'
select @fieldname = 'CCNO'
set nocount on

select so.name from syscolumns sc, sysobjects so
where sc.id = so.id
and
--where
sc.name = @fieldname
order by so.name
