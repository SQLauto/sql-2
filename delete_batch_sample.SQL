
DECLARE @BatchSize INT
SET @BatchSize = 5000
WHILE @BatchSize <> 0
BEGIN 
DELETE TOP (@BatchSize)
FROM pc_data_workattach
SET @BatchSize = @@rowcount 
END
