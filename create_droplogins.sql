SET NOCOUNT ON
SELECT 'DROP LOGIN [' + loginname + ']'
FROM master.dbo.syslogins
WHERE name NOT IN ('sa')
AND name NOT LIKE ('##%')
AND isntname = 0

/*
and loginname in 
(
'ANON',
'GAUTAMB',
'MLABRA',
'GLENN',
'ANTHONYB',
'ERICG',
'JOHNHU',
'ADRIANJ',
'SARAJ', 
'GUSTAVOB',
'LEMARI',
'JODIK',
'OMARC',
'YJIMENEZ',
'JUSTINR',
'JEANNIEC',
'NOREENH', 
'YANZAW',
'TONYECAG',
'MICHAELHA',
'MIR01',
'MIR02',
'MIR03',
'MIR04',
'MIR05',
'JESSICAY'

)
*/
