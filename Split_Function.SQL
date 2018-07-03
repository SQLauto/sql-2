CREATE FUNCTION FNC_SPLIT(@MYSTR VARCHAR(500), @DELIMITER CHAR(1))
RETURNS @MYTBL  TABLE (idx smallint, value varchar(8000))
AS 
BEGIN
 DECLARE @RET VARCHAR(500)
 DECLARE @INDEX INT
 DECLARE @COUNTER smallint
 
 --Get the first position of delimiter in the main string
 SET @INDEX = CHARINDEX(@DELIMITER,@MYSTR)
 SET @COUNTER = 0
 
 --Loop if delimiter exists in the main string
 WHILE @INDEX > 0
 BEGIN
  --extract the result substring before the delimiter found
  SET @RET = SUBSTRING(@MYSTR,1, @INDEX-1 )
  --set mainstring right part after the delimiter found
  SET @MYSTR = SUBSTRING(@MYSTR,@INDEX+1 , LEN(@MYSTR) - @INDEX )
  --increase the counter
  SET @COUNTER = @COUNTER  + 1 
  --add the result substring to the table
  INSERT INTO @MYTBL (idx, value)
  VALUES (@COUNTER, @RET)
  --Get the next position of delimiter in the main string
  SET @INDEX = CHARINDEX(@DELIMITER,@MYSTR)
 END
 
 --if no delimiter is found then simply add the mainstring to the table
 IF @INDEX = 0 
 BEGIN
  SET @COUNTER = @COUNTER  + 1
  INSERT INTO @MYTBL (idx, value)
  VALUES (@COUNTER, @MYSTR)
 END 
 RETURN   
END