DECLARE @String VARCHAR(100)
SET @String = 'TEST STRING'

-- Chop off the end character
SET @String = LEFT(@String, LEN(@String) - 1)

SELECT @String