SELECT --TOP 100
--REPLICATE(' ',4000) AS COLNAMES ,
--OBJECT_NAME(I.ID) AS TABLENAME,
--I.ID AS TABLEID,
--I.INDID AS INDEXID,
I.NAME AS INDEXNAME
--,
--I.STATUS,
--INDEXPROPERTY (I.ID,I.NAME,'ISUNIQUE') AS ISUNIQUE,
--INDEXPROPERTY (I.ID,I.NAME,'ISCLUSTERED') AS ISCLUSTERED,
--INDEXPROPERTY (I.ID,I.NAME,'INDEXFILLFACTOR') AS INDEXFILLFACTOR
--,*
--INTO #TMP
FROM SYSINDEXES I
WHERE I.INDID > 0 
AND I.INDID < 255 
AND (I.STATUS & 64)=0
and 
OBJECT_NAME(I.ID) in
(
	select name
	from sysobjects where type = 'u' and category <> 2 and status > 0
)
order by I.NAME
--select * from #tmp
--drop table #tmp