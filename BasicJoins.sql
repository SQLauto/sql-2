USE Master;

--IF EXISTS(SELECT name FROM sys.databases WHERE name = 'BasicJoins')
--BEGIN
--ALTER DATABASE BasicJoins SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--DROP DATABASE BasicJoins;
--END
CREATE DATABASE BasicJoins;
GO
 
USE BasicJoins;





-- Tables to be used for the article
CREATE TABLE dbo.People
(
	PeopleID int IDENTITY(1,1) NOT NULL,
	Name varchar(100) NOT NULL,
 CONSTRAINT PK_People PRIMARY KEY CLUSTERED ( PeopleID ASC ) 
) ;


CREATE TABLE dbo.PhoneNumbers
(
	PhoneNumberID int IDENTITY(1,1) NOT NULL,
	PeopleID int NULL,
	Number varchar(50) NOT NULL,
 CONSTRAINT PK_PhoneNumbers PRIMARY KEY CLUSTERED ( PhoneNumberID ASC ) 
) ;

ALTER TABLE dbo.PhoneNumbers ADD CONSTRAINT FK_PhoneNumbers_People FOREIGN KEY(PeopleID)
REFERENCES dbo.People (PeopleID);




GO


INSERT INTO dbo.People (Name) VALUES ('Steve');
INSERT INTO dbo.People (Name) VALUES ('Marcia');
INSERT INTO dbo.People (Name) VALUES ('Alex');
INSERT INTO dbo.People (Name) VALUES ('George');
INSERT INTO dbo.People (Name) VALUES ('Pete');
INSERT INTO dbo.People (Name) VALUES ('Ann');
INSERT INTO dbo.People (Name) VALUES ('Jack');
INSERT INTO dbo.People (Name) VALUES ('Donna');
INSERT INTO dbo.People (Name) VALUES ('Karen');

GO

-- multiple insert statements to accomodate SQL Server 2005
INSERT INTO dbo.PhoneNumbers (PeopleID, Number)
     VALUES (1, '360 111-1234');
INSERT INTO dbo.PhoneNumbers (PeopleID, Number)
     VALUES (2, '360 222-2222');
INSERT INTO dbo.PhoneNumbers (PeopleID, Number)
     VALUES (3, '360 333-4321');
INSERT INTO dbo.PhoneNumbers (PeopleID, Number)
     VALUES (4, '206 444-5432');
INSERT INTO dbo.PhoneNumbers (PeopleID, Number)
     VALUES (5, '206 555-9876');
INSERT INTO dbo.PhoneNumbers (PeopleID, Number)
     VALUES (6, '206 666-5634');
INSERT INTO dbo.PhoneNumbers (PeopleID, Number)
     VALUES (NULL, '206 777-8888');
GO




SELECT PeopleID
      ,Name
  FROM dbo.People;

SELECT PhoneNumberID
      ,PeopleID
      ,Number
  FROM dbo.PhoneNumbers;
GO


GO


--INNER JOIN
SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID
	  ,n.PeopleID, n.Number
  FROM dbo.People p
 INNER JOIN dbo.PhoneNumbers n 
    ON p.PeopleID = n.PeopleID;


SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID, n.PeopleID, n.Number 
  FROM dbo.People p
  JOIN dbo.PhoneNumbers n ON p.PeopleID = n.PeopleID;
GO



--LEFT OUTER JOIN
SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID
	  ,n.PeopleID, n.Number 
  FROM dbo.People p
  LEFT JOIN dbo.PhoneNumbers n 
    ON p.PeopleID = n.PeopleID;
GO


--RIGHT OUTER JOIN
SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID
	  ,n.PeopleID, n.Number 
  FROM dbo.People p
 RIGHT JOIN dbo.PhoneNumbers n 
    ON p.PeopleID = n.PeopleID;
GO




--RIGHT OUTER JOIN producing the same results as a LEFT OUTER JOIN

SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID, n.PeopleID, n.Number 
  FROM dbo.People p
  LEFT JOIN dbo.PhoneNumbers n 
    ON p.PeopleID = n.PeopleID;

SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID, n.PeopleID, n.Number 
  FROM dbo.PhoneNumbers n
 RIGHT JOIN dbo.People p
    ON p.PeopleID = n.PeopleID;




-- Give me all the People who don't have phone numbers

-- Alternative to LEFT OUTER JOIN with exclusion is the NOT IN 
SELECT p.PeopleID, p.Name
  FROM dbo.People p
 WHERE p.PeopleID NOT IN (SELECT n.PeopleID 
                            FROM dbo.PhoneNumbers n
   						   WHERE n.PeopleID IS NOT NULL);

--LEFT OUTER JOIN with exclusion
SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID
	  ,n.PeopleID, n.Number 
  FROM dbo.People p
  LEFT JOIN dbo.PhoneNumbers n 
    ON p.PeopleID = n.PeopleID
 WHERE n.PhoneNumberID IS NULL;  


--LEFT OUTER JOIN with exclusion  DONE WRONG... DANGER 
SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID
	  ,n.PeopleID, n.Number 
  FROM dbo.People p
  LEFT JOIN dbo.PhoneNumbers n 
    ON p.PeopleID = n.PeopleID AND n.PhoneNumberID IS NULL;  











-- Give me all the phone numbers not associated with people

--RIGHT OUTER JOIN with exclusion
SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID
	  ,n.PeopleID, n.Number  
  FROM dbo.People p
 RIGHT JOIN dbo.PhoneNumbers n 
    ON p.PeopleID = n.PeopleID
 WHERE p.PeopleID IS NULL;  

 SELECT n.PhoneNumberID, n.PeopleID, n.Number  
   FROM dbo.PhoneNumbers n 
  WHERE n.PeopleID IS NULL;

GO


 


-- FULL OUTER JOIN
SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID
	  ,n.PeopleID, n.Number 
  FROM dbo.People p
  FULL JOIN dbo.PhoneNumbers n 
    ON p.PeopleID = n.PeopleID;



-- FULL OUTER JOIN - with exclusions
SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID
	  ,n.PeopleID, n.Number 
  FROM dbo.People p
  FULL JOIN dbo.PhoneNumbers n 
    ON p.PeopleID = n.PeopleID
 WHERE p.PeopleID IS NULL 
    OR n.PeopleID IS NULL;
  







-- CROSS JOIN
SELECT p.PeopleID, p.Name
	  ,n.PhoneNumberID, n.PeopleID, n.Number 
  FROM dbo.People p
 CROSS JOIN dbo.PhoneNumbers n;



--DELETE JOIN
DELETE w
FROM WorkRecord2 w
INNER JOIN Employee e
  ON EmployeeRun=EmployeeNo
Where Company = '1' AND Date = '2013-05-06'



--UPDATE with join
update u
set u.assid = s.assid
from ud u
    inner join sale s on
        u.id = s.udid
	
	
--INSERT WITH JOIN

INSERT INTO [DB_A].[dbo.a_test](a,b,c, d)
    select p.product_info, p.product_date, p.smth, pr.program_name, pr.program_smth
    FROM [DB_B].dbo.products p LEFT JOIN
         [DB_B].dbo.program pr
         ON p.program_name = pr.product_info;