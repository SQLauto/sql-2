declare @shifts varchar(1000)
set @shifts = ''
SELECT @shifts + ATCR_COLUMN + ','  FROM TB_AGENCY_ATCR_DESC WHERE ATCR_DESC <> 'NOT DEFINED'
