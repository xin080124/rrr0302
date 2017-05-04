-------------------------------------------------------
--Data Quality Checking and Logging for Data Warehouse
--Check For DW: 	My First Northwind DW
--Student ID:   	######
--Student Name: 	MyName MySurname
-------------------------------------------------------
-- DROP TABLE DQLog;
-- CREATE TABLE DQLog
-- (
-- LogID 		int PRIMARY KEY IDENTITY,
-- RowID 		varbinary(32),		-- This is a physical address of a row stored on a disk and it is UNIQUE
-- DBName 		nchar(20),
-- TableName	nchar(20),
-- RuleNo		smallint,
-- Action		nchar(6) CHECK (action IN ('allow','fix','reject')) -- Action can be ONLY 'allow','fix','reject'
-- );

--check all product in northwind 5
INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'Northwind5','Products',1,'reject'
FROM Northwind5.dbo.Products
WHERE UnitPrice<=0

print '***************************************************************'
print '****** Section 2: DQ Checking and Logging based on DQ Rules'
print '***************************************************************'

print '================ BEGIN RULE 1 CHECKING =================='
print 'DQ Rule 1: 	UnitPrice is 0 or negative'
print 'Action: 		Reject'
print 'Database: 	Northwind5 and northwind6'
print '------------------------'
print 'Table: 		Products'
print '------------------------'
-- From Week 8 Worksheet - Step D.1. 
-- Write your SQL statement below... 


-- From Week 8 Worksheet - Step D.2. 
-- Write your SQL statement below... 


-- From Week 8 Worksheet - Step D.3. 
-- Write your SQL statement below... 


print '------------------------'
print 'Table: 		[Order Details]'
print '------------------------'
-- From Week 8 Worksheet - Step D.4. 
-- Write your SQL statement below... 

-- From Week 8 Worksheet - Step D.5. 
-- Write your SQL statement below... 


-- From Week 8 Worksheet - Step D.6. 
-- Write your SQL statement below... 


print '=============== END RULE 1 CHECKING ===================='


print '================ BEGIN RULE 2 CHECKING =================='
print 'DQ Rule 2: 	Quantity is 0 or negative'
print 'Action: 		Reject'
print 'Database: 	Northwind5 and northwind6'
print '------------------------'
print 'Table: 		[Order Details]'
print '------------------------'
-- From Week 8 Worksheet - Step E. 
-- Write your SQL statement below... 


print '=============== END RULE 2 CHECKING ===================='


print '================ BEGIN RULE 3 CHECKING =================='
print 'DQ Rule 3: 	Discount is more than 50% (0.50)'
print 'Action: 		Allow'
print 'Database: 	Northwind5 and northwind6'
print '------------------------'
print 'Table: 		[Order Details]'
print '------------------------'
-- From Week 8 Worksheet - Step F. 
-- Write your SQL statement below... 


print '=============== END RULE 3 CHECKING ===================='


print '================ BEGIN RULE 4 CHECKING =================='
print 'DQ Rule 4: 	Customer with wrong Country format'
print 'Action: 		Fix'
print 'Database: 	Northwind5 and northwind6'
print '------------------------'
print 'Table: 		Customers'
print '------------------------'
-- From Week 8 Worksheet - Step G. 
-- Write your SQL statement below... 


print '=============== END RULE 4 CHECKING ===================='


print '================ BEGIN RULE 5 CHECKING ===================='
print 'DQ Rule 5: 	US Customer with the length of PostalCode is not 5'
print 'Action: 		Allow'
print 'Database: 	Only Northwind5' -- Why does northwind6 not need to be checked?
print '------------------------'
print 'Table: 		Customers'
print '------------------------'
-- From Week 8 Worksheet - Step H. 
-- Write your SQL statement below... 


print '=============== END RULE 5 CHECKING ======================'


print '================ BEGIN RULE 6 CHECKING ===================='
print 'DQ Rule 6: 	CategoryID checking in Products (if exists or null)'
print 'Action: 		Allow'
print 'Database: 	Northwind5 and northwind6'
print '------------------------'
print 'Table: 		Products'
print '------------------------'
-- From Week 8 Worksheet - Step I. 
-- Write your SQL statement below... 


print '=============== END RULE 6 CHECKING ======================'

-- **************************************************************
-- PLEASE FILL IN NUMBERS IN THE ##### BELOW
-- **************************************************************
-- Rule no	| 	Total Logged Rows
-- **************************************************************
-- 1			####
-- 2			####
-- 3			####
-- 4			####
-- 5			####
-- 6			####
-- **************************************************************
-- Total Allow 	####
-- Total Fix 	####
-- Total Reject	####
-- **************************************************************
