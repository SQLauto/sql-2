-- DROP PROCEDURE sql2pdf
CREATE PROCEDURE sql2pdf
   @filename VARCHAR(100) 
AS 
  CREATE TABLE #pdf (idnumber INT IDENTITY(1,1)
  		    ,code NVARCHAR(200))
  CREATE TABLE #xref (idnumber INT IDENTITY(1,1)
  		    ,code VARCHAR(30))
  CREATE TABLE #text (idnumber INT IDENTITY(1,1)
  		    ,code VARCHAR(200))

  DECLARE @end VARCHAR(7),
  	@beg   VARCHAR(7),
  	@a1    VARCHAR(3),
  	@a2    VARCHAR(3),
  	@ad    VARCHAR(5),
  	@cr    VARCHAR(8),
  	@pr    VARCHAR(9),
  	@ti    VARCHAR(6),
  	@xstr  VARCHAR(10),
  	@page  VARCHAR(8000),
	@pdf   VARCHAR(100),
	@trenutniRed NVARCHAR(200),
  	@rows   INT,
  	@ofset  INT,
  	@len    INT,
  	@nopg   INT,
        @fs 	INT,
	@ole    INT,
	@x 	INT,
	@file   INT,
  	@object INT
  SELECT @pdf = 'C:\' + @filename + '.pdf'  
  SET @page = ''
  SET @nopg = 0
  SET @object = 6
  SET @end = 'endobj'
  SET @beg = ' 0 obj'
  SET @a1 = '<<'
  SET @a2 = '>>'
  SET @ad = ' 0 R'
  SET @cr = CHAR(67) + CHAR(114) + CHAR (101) + CHAR(97) + CHAR(116) + CHAR (111) + CHAR(114)
  SET @pr = CHAR(80) + CHAR(114) + CHAR (111) + CHAR(100) + CHAR(117) + CHAR (99 ) + CHAR(101) + CHAR(114)
  SET @ti = CHAR(84) + CHAR(105) + CHAR (116) + CHAR(108) + CHAR(101)
  SET @xstr = ' 00000 n'
  SET @ofset = 396  
  INSERT INTO #xref(code) VALUES ('xref')
  INSERT INTO #xref(code) VALUES ('0 10')
  INSERT INTO #xref(code) VALUES ('0000000000 65535 f')
  INSERT INTO #xref(code) VALUES ('0000000017' + @xstr)
  INSERT INTO #xref(code) VALUES ('0000000790' + @xstr)
  INSERT INTO #xref(code) VALUES ('0000000869' + @xstr)
  INSERT INTO #xref(code) VALUES ('0000000144' + @xstr)
  INSERT INTO #xref(code) VALUES ('0000000247' + @xstr)
  INSERT INTO #xref(code) VALUES ('0000000321' + @xstr)
  INSERT INTO #xref(code) VALUES ('0000000396' + @xstr)  
  INSERT INTO #pdf (code) VALUES ('%' + CHAR(80) + CHAR(68) + CHAR (70) + '-1.2')
  INSERT INTO #pdf (code) VALUES ('%сссс')
  INSERT INTO #pdf (code) VALUES ('1' + @beg)
  INSERT INTO #pdf (code) VALUES (@a1)
  INSERT INTO #pdf (code) VALUES ('/' + @cr + ' (Ivica Masar ' + CHAR(80) + CHAR(83) + CHAR (79) + CHAR(80) + CHAR(68) + CHAR (70) + ')')
  INSERT INTO #pdf (code) VALUES ('/' + @pr + ' (stored procedure for ms sql  pso@vip.hr)')
  INSERT INTO #pdf (code) VALUES ('/' + @ti + ' (SQL2' + CHAR(80) + CHAR(68) + CHAR (70) + ')')
  INSERT INTO #pdf (code) VALUES (@a2)
  INSERT INTO #pdf (code) VALUES (@end)
  INSERT INTO #pdf (code) VALUES ('4' + @beg)
  INSERT INTO #pdf (code) VALUES (@a1)
  INSERT INTO #pdf (code) VALUES ('/Type /Font')
  INSERT INTO #pdf (code) VALUES ('/Subtype /Type1')
  INSERT INTO #pdf (code) VALUES ('/Name /F1')
  INSERT INTO #pdf (code) VALUES ('/Encoding 5' + @ad)
  INSERT INTO #pdf (code) VALUES ('/BaseFont /Courier')
  INSERT INTO #pdf (code) VALUES (@a2)
  INSERT INTO #pdf (code) VALUES (@end)
  INSERT INTO #pdf (code) VALUES ('5' + @beg)
  INSERT INTO #pdf (code) VALUES (@a1)
  INSERT INTO #pdf (code) VALUES ('/Type /Encoding')
  INSERT INTO #pdf (code) VALUES ('/BaseEncoding /WinAnsiEncoding')
  INSERT INTO #pdf (code) VALUES (@a2)
  INSERT INTO #pdf (code) VALUES (@end)
  INSERT INTO #pdf (code) VALUES ('6' + @beg)
  INSERT INTO #pdf (code) VALUES (@a1)
  INSERT INTO #pdf (code) VALUES ('  /Font ' + @a1 + ' /F1 4' + @ad + ' ' + @a2 + '  /ProcSet [ /' + CHAR(80) + CHAR(68) + CHAR (70) + ' /Text ]')
  INSERT INTO #pdf (code) VALUES (@a2)
  INSERT INTO #pdf (code) VALUES (@end)
  INSERT INTO #text(code) (SELECT code FROM psopdf)
  SELECT @x = COUNT(*) FROM #text
  SELECT @x = (@x / 60) + 1
  WHILE  @nopg < @x
    BEGIN
      DECLARE SysKursor  INSENSITIVE SCROLL CURSOR 
      FOR SELECT SUBSTRING((code + SPACE(81)), 1, 80) FROM #text WHERE idnumber BETWEEN ((@nopg * 60) + 1) AND ((@nopg + 1) * 60 )
      FOR READ ONLY    
      OPEN SysKursor
      FETCH NEXT FROM SysKursor INTO @trenutniRed
      SELECT @object = @object + 1
      SELECT @page = @page +  ' ' + CAST(@object AS VARCHAR) + @ad
      SELECT @len = LEN(@object) + LEN(@object + 1)
      INSERT INTO #pdf (code) VALUES (CAST(@object AS VARCHAR)  + @beg)
      INSERT INTO #pdf (code) VALUES (@a1)
      INSERT INTO #pdf (code) VALUES ('/Type /Page')
      INSERT INTO #pdf (code) VALUES ('/Parent 3' + @ad)
      INSERT INTO #pdf (code) VALUES ('/Resources 6' + @ad)
      SELECT @object = @object + 1
      INSERT INTO #pdf (code) VALUES ('/Contents ' + CAST(@object AS VARCHAR) + @ad)
      INSERT INTO #pdf (code) VALUES (@a2)
      INSERT INTO #pdf (code) VALUES (@end)
      SELECT @ofset = @len + 86 + @ofset
      INSERT INTO #xref(code) (SELECT SUBSTRING('0000000000' + CAST(@ofset AS VARCHAR), 
    	LEN('0000000000' + CAST(@ofset AS VARCHAR)) - 9, 
    	LEN('0000000000' + CAST(@ofset AS VARCHAR))) + @xstr)  
      INSERT INTO #pdf (code) VALUES (CAST(@object AS VARCHAR)  + @beg)
      INSERT INTO #pdf (code) VALUES (@a1)
      SELECT @object = @object + 1
      INSERT INTO #pdf (code) VALUES ('/Length ' + CAST(@object AS VARCHAR) + @ad)
      INSERT INTO #pdf (code) VALUES (@a2)
      INSERT INTO #pdf (code) VALUES ('stream')
      INSERT INTO #pdf (code) VALUES ('BT')
      INSERT INTO #pdf (code) VALUES ('/F1 10 Tf')
      INSERT INTO #pdf (code) VALUES ('1 0 0 1 50 802 Tm')
      INSERT INTO #pdf (code) VALUES ('12 TL')
      WHILE @@Fetch_Status = 0
         BEGIN
             INSERT INTO #pdf (code) VALUES ('T* (' + @trenutniRed + ') Tj')
             FETCH NEXT FROM  SysKursor INTO @trenutniRed
          END
      INSERT INTO #pdf (code) VALUES ('ET')
      INSERT INTO #pdf (code) VALUES ('endstream')
      INSERT INTO #pdf (code) VALUES (@end)
      SELECT @rows = (SELECT COUNT(*) FROM #text WHERE idnumber BETWEEN ((@nopg * 60) + 1) AND ((@nopg + 1) * 60 ))* 90 + 45
      SELECT @nopg = @nopg + 1    
      SELECT @len = LEN(@object) + LEN(@object - 1)
      SELECT @ofset = @len + 57 + @ofset + @rows
      INSERT INTO #xref(code) (SELECT SUBSTRING('0000000000' + CAST(@ofset AS VARCHAR), 
     	LEN('0000000000' + CAST(@ofset AS VARCHAR)) - 9, 
   	LEN('0000000000' + CAST(@ofset AS VARCHAR))) + @xstr)   
      INSERT INTO #pdf (code) VALUES (CAST(@object AS VARCHAR)  + @beg)
      INSERT INTO #pdf (code) VALUES (@rows)
      INSERT INTO #pdf (code) VALUES (@end)
      SELECT @len = LEN(@object) + LEN(@rows)
      SELECT @ofset = @len + 18 + @ofset
      INSERT INTO #xref(code) (SELECT SUBSTRING('0000000000' + CAST(@ofset AS VARCHAR), 
    	LEN('0000000000' + CAST(@ofset AS VARCHAR)) - 9, 
    	LEN('0000000000' + CAST(@ofset AS VARCHAR))) + @xstr)  
      CLOSE SysKursor
      DEALLOCATE SysKursor
    END
    INSERT INTO #pdf (code) VALUES ('2' + @beg)
    INSERT INTO #pdf (code) VALUES (@a1)
    INSERT INTO #pdf (code) VALUES ('/Type /Catalog')
    INSERT INTO #pdf (code) VALUES ('/Pages 3' + @ad)
    INSERT INTO #pdf (code) VALUES ('/PageLayout /OneColumn')
    INSERT INTO #pdf (code) VALUES (@a2)
    INSERT INTO #pdf (code) VALUES (@end)
    UPDATE #xref SET code = (SELECT code FROM #xref WHERE idnumber = (SELECT MAX(idnumber) FROM #xref)) WHERE idnumber = 5
    DELETE FROM #xref WHERE idnumber = (SELECT MAX(idnumber) FROM #xref)
    INSERT INTO #pdf (code) VALUES ('3' + @beg)
    INSERT INTO #pdf (code) VALUES (@a1)
    INSERT INTO #pdf (code) VALUES ('/Type /Pages')
    INSERT INTO #pdf (code) VALUES ('/Count ' + CAST(@nopg AS VARCHAR))
    INSERT INTO #pdf (code) VALUES ('/MediaBox [ 0 0 595 842 ]')
    INSERT INTO #pdf (code) VALUES ('/Kids [' + @page + ' ]')
    INSERT INTO #pdf (code) VALUES (@a2)
    INSERT INTO #pdf (code) VALUES (@end)
    SELECT @ofset = @ofset + 79
    UPDATE #xref SET code =(SELECT SUBSTRING('0000000000' + CAST(@ofset AS VARCHAR), 
  	LEN('0000000000' + CAST(@ofset AS VARCHAR)) - 9, 
  	LEN('0000000000' + CAST(@ofset AS VARCHAR))) + @xstr) WHERE idnumber = 6
    INSERT INTO #xref(code) VALUES ('trailer')
    INSERT INTO #xref(code) VALUES (@a1)
    SELECT @object = @object + 1
    UPDATE #xref SET code = '0 ' + CAST(@object AS VARCHAR) WHERE idnumber = 2
    INSERT INTO #xref(code) VALUES ('/Size ' + CAST(@object AS VARCHAR))
    INSERT INTO #xref(code) VALUES ('/Root 2' + @ad)
    INSERT INTO #xref(code) VALUES ('/Info 1' + @ad)
    INSERT INTO #xref(code) VALUES (@a2)
    INSERT INTO #xref(code) VALUES ('startxref')
    SELECT @len = LEN(@nopg) + LEN(@page)
    SELECT @ofset = @len + 86 + @ofset
    INSERT INTO #xref(code) VALUES (@ofset)
    INSERT INTO #xref(code) VALUES ('%%' + CHAR(69) + CHAR (79) + CHAR(70))
    INSERT INTO #pdf (code) (SELECT code FROM #xref) 
    --SELECT code FROM #pdf
    SELECT @trenutniRed = 'del '+ @pdf
    EXECUTE @ole = sp_OACreate 'Scripting.FileSystemObject', @fs OUT
    EXEC master..xp_cmdshell @trenutniRed, NO_OUTPUT

    EXECUTE @ole = sp_OAMethod @fs, 'OpenTextFile', @file OUT, @pdf, 8, 1

    DECLARE SysKursor  INSENSITIVE SCROLL CURSOR 
    FOR SELECT code FROM #pdf ORDER BY idnumber
    FOR READ ONLY    
    OPEN SysKursor
    FETCH NEXT FROM SysKursor INTO @trenutniRed
    WHILE @@Fetch_Status = 0
	BEGIN
	  EXECUTE @ole = sp_OAMethod @file, 'WriteLine', Null, @trenutniRed
	  FETCH NEXT FROM  SysKursor INTO @trenutniRed 
        END
    CLOSE SysKursor
    DEALLOCATE SysKursor
    DELETE FROM psopdf
    EXECUTE @ole = sp_OADestroy @file
    EXECUTE @ole = sp_OADestroy @fs
