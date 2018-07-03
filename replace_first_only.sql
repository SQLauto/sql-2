 DECLARE @find varchar(8000)
SELECT @find='Replace this'
UPDATE myTable
SET myCol=Stuff(myCol, CharIndex(@find, myCol), Len(@find), 'Replacement text')