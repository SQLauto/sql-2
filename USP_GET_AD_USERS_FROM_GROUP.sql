
/****** Object:  StoredProcedure [dbo].[USP_GET_AD_USERS_FROM_GROUP]    Script Date: 5/12/2017 12:40:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jorge Besada
-- Create date: 5/12/2017
-- Description:	Returns list of active directory members of group
--to test
--Carnival
--EXEC USP_GET_AD_USERS_FROM_GROUP 'ECOM SQL SUPPORT'
--Shiptech
--EXEC USP_GET_AD_USERS_FROM_GROUP 'Domain Admins'
-- =============================================
CREATE PROCEDURE [dbo].[USP_GET_AD_USERS_FROM_GROUP] 
	-- Pass the group
	@Param1 varchar(500) 
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #ad_import
	([ad_line] [varchar](1000) NULL)
	CREATE TABLE #ad_output
	([ad_line] [varchar](1000) NULL)
	CREATE TABLE #ad_final
	([ad_line] [varchar](1000) NULL)
	truncate table ad_import

	declare @cmd varchar(200)
	set @cmd = 'net group "' + @param1 + '" /domain'
	
	--truncate table #ad_import
	INSERT INTO #ad_import ([ad_line])
	exec xp_cmdshell @cmd

	

	insert into #ad_output
	select ad_line from #ad_import
	where left(ad_line, 11)  not in
	(
	'The request',
	'Group name ',
	'Comment    ',
	'Members    ',
	'-----------'
	)
	and ad_line is not null
	--select * from #ad_output
	--creating cursor here------------------------------
	DECLARE C1 CURSOR
		READ_ONLY
		FOR select ad_line from #ad_output

		--DECLARE @name varchar(400)
		declare @String VARCHAR(MAX)
		declare @Delimiter VARCHAR(5)
		DECLARE @auxString	VARCHAR(MAX)
		set @Delimiter = ' '

		OPEN C1

		FETCH NEXT FROM C1 INTO @String
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				-- start of split section------------------------	
				SET @auxString = REPLACE(@String, @Delimiter,'.');
				WITH Split(stpos,endpos)
				AS(
				SELECT 0 AS stpos, CHARINDEX('.',@auxString) AS endpos
				UNION ALL
				SELECT CAST(endpos AS INT)+1, CHARINDEX('.',@auxString,endpos+1)
				FROM Split
				WHERE endpos > 0
				)
				insert into #ad_final
				SELECT SUBSTRING(@auxString,stpos,COALESCE(NULLIF(endpos,0),LEN(@auxString)+1)-stpos) 
				FROM Split
				WHERE SUBSTRING(@auxString,stpos,COALESCE(NULLIF(endpos,0),LEN(@auxString)+1)-stpos) > ''
			-- end of split section------------------------
			END
			FETCH NEXT FROM C1 INTO @String
		END

		CLOSE C1
		DEALLOCATE C1
	--end of cursor-------------------------------------
	insert into ad_import(ad_line) select ad_line from #ad_final
	where 
	left(ad_line, 10) <> '----------' and
	ad_line not in ('The','command','completed','successfully') 

	
END

GO


