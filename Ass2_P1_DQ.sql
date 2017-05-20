-------------------------------------------------------
--Data Warehousing Assignment 2 - Phase 1
--Data Quality Checking and Logging for Data Warehouse
--Check For DW: 	My Northwind DW
--Student ID:   	
--Student Name: 	
--Student ID:   	#######
--Student Name: 	MyName MySurname
--Student ID:   	1472041
--Student Name: 	Ji Wang
-------------------------------------------------------

print '***************************************************************'
print '****** Section 1: DQLog table'
print '***************************************************************'
--SQL statements to DROP and CREATE a DQLog table
DROP TABLE DQLog;
CREATE TABLE DQLog
(
LogID 		int PRIMARY KEY IDENTITY,
RowID 		varbinary(32),		
DBName 		nchar(20),
TableName	nchar(20),
RuleNo		smallint,
Action		nchar(6) CHECK (action IN ('allow','fix','reject')) 
);

print '***************************************************************'
print '****** Section 2: DQ Checking and Logging based on DQ Rules'
print '***************************************************************'

print '================ BEGIN RULE 01 CHECKING =================='
print 'DQ Rule 01: 	UnitPrice is negative or null'
print 'Action: 		Reject'
print 'Database: 	Northwind7 and northwind8'
print '------------------------'
print 'Table: 		Products'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Products',1,'Reject'
FROM northwind7.dbo.Products
WHERE UnitPrice < 0 OR UnitPrice IS NULL;

--2 pruducts found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Products',1,'Reject'
FROM northwind8.dbo.Products
WHERE UnitPrice < 0 OR UnitPrice IS NULL;

--0 products found in nw8

print '=============== END RULE 01 CHECKING ===================='


print '================ BEGIN RULE 02 CHECKING =================='
print 'DQ Rule 02: 	Quantity is negative or null'
print 'Action: 		Reject'
print 'Database: 	Northwind7 and northwind8'
print '------------------------'
print 'Table: 		Order Details'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Order Details',2,'Reject'
FROM northwind7.dbo.[Order Details]
WHERE Quantity < 0 OR Quantity IS NULL;

--1 order found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Order Details',2,'Reject'
FROM northwind8.dbo.[Order Details]
WHERE Quantity < 0 OR Quantity IS NULL;

--0 order found in nw8

print '=============== END RULE 02 CHECKING ===================='


print '================ BEGIN RULE 03 CHECKING =================='
print 'DQ Rule 03: 	Discount > 70% (0.7) on a product that has UnitPricegreater than $400'
print 'Action: 		Allow'
print 'Database: 	Northwind7 and northwind8'
print '------------------------'
print 'Table: 		Order Details'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Order Details',3,'Allow'
FROM northwind7.dbo.[Order Details]
WHERE UnitPrice > 400 AND Discount > 0.7;

--0 order found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Order Details',3,'Allow'
FROM northwind8.dbo.[Order Details]
WHERE UnitPrice > 400 AND Discount > 0.7;

--0 order found in nw8

print '=============== END RULE 03 CHECKING ===================='


print '================ BEGIN RULE 04 CHECKING =================='
print 'DQ Rule 04: 	Customer with wrong Country format'
print 'Action: 		Fix'
print 'Database: 	Northwind7 and northwind8'
print '------------------------'
print 'Table: 		Customers and Suppliers'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Customers',4,'Fix'
FROM northwind7.dbo.Customers
WHERE Country IN ('us', 'united states', 'britain', 'united kingdom');

--2 customers found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Suppliers',4,'Fix'
FROM northwind7.dbo.Suppliers
WHERE Country IN ('us', 'united states', 'britain', 'united kingdom');

--1 supplier found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Customers',4,'Fix'
FROM northwind8.dbo.Customers
WHERE Country IN ('us', 'united states', 'britain', 'united kingdom');

--2 customers found in nw8

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Suppliers',4,'Fix'
FROM northwind8.dbo.Suppliers
WHERE Country IN ('us', 'united states', 'britain', 'united kingdom');

--0 supplier found in nw8

print '=============== END RULE 04 CHECKING ===================='


print '================ BEGIN RULE 05 CHECKING =================='
print 'DQ Rule 05: 	Us Customers with Post Code Length is not 5'
print 'Action: 		Allow'
print 'Database: 	Northwind7'
print '------------------------'
print 'Table: 		Customers'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Customers',5,'Allow'
FROM northwind7.dbo.customers
WHERE LEN(postalcode) != 5;

--2 customers found in nw7

print '=============== END RULE 05 CHECKING ===================='


print '================ BEGIN RULE 06 CHECKING =================='
print 'DQ Rule 06: 	product that belongs to a non-existing category/supplier'
print 'Action: 		Reject'
print 'Database: 	Northwind7 and Northwind8'
print '------------------------'
print 'Table: 		Products'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Products',6,'Reject'
FROM northwind7.dbo.Products
WHERE CategoryID  NOT IN 
		(SELECT CategoryID 
		 FROM northwind7.dbo.Categories)
	 OR CategoryID IS NULL
	 OR SupplierID NOT IN 
	 	(SELECT SupplierID 
		 FROM northwind7.dbo.Suppliers) 
	 OR SupplierID IS NULL;

--2 products found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Products',6,'Reject'
FROM northwind8.dbo.Products
WHERE CategoryID NOT IN 
		(SELECT CategoryID
		 FROM northwind8.dbo.Categories) 
	 OR CategoryID IS NULL
	 OR SupplierID NOT IN 
	 	(SELECT SupplierID
		 FROM northwind8.dbo.Suppliers) 
	 OR SupplierID IS NULL;

--2 products found in nw8

print '=============== END RULE 06 CHECKING ===================='


print '================ BEGIN RULE 07 CHECKING =================='
print 'DQ Rule 07: 	ProductID doesn’t exist or is null'
print 'Action: 		Reject'
print 'Database: 	Northwind7 and northwind8'
print '------------------------'
print 'Table: 		Order Details'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Order Details',7,'Reject'
FROM northwind7.dbo.[Order Details]
WHERE ProductID NOT IN 
	(SELECT ProductID
	 FROM northwind7.dbo.Products) 
	OR ProductID IS NULL;

--0 order found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Order Details',7,'Reject'
FROM northwind8.dbo.[Order Details]
WHERE ProductID NOT IN 
	(SELECT ProductID
	 FROM northwind8.dbo.Products)
	 OR ProductID IS NULL;

--2 orders found in nw8

print '=============== END RULE 07 CHECKING ===================='


print '================ BEGIN RULE 08 CHECKING =================='
print 'DQ Rule 08: 	(CustomerID doesn’t exist or is null) and (both ShipAddress and ShipCity are null)'
print 'Action: 		Reject'
print 'Database: 	Northwind7 and Northwind8'
print '------------------------'
print 'Table: 		Orders'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Orders',8,'Reject'
FROM northwind7.dbo.Orders
WHERE (CustomerID NOT IN 
		(SELECT CustomerID
		 FROM northwind7.dbo.Customers)
	OR CustomerID IS NULL)
	AND (ShipAddress IS NULL AND ShipCity IS NULL);

--0 order found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Orders',8,'Reject'
FROM northwind8.dbo.Orders
WHERE (CustomerID NOT IN 
		(SELECT CustomerID
		 FROM northwind8.dbo.Customers)
	OR CustomerID IS NULL)
	AND (ShipAddress IS NULL AND ShipCity IS NULL);

--2 orders found in nw8

print '=============== END RULE 08 CHECKING ===================='


print '================ BEGIN RULE 09 CHECKING =================='
print 'DQ Rule 09: 	non-existing Shipper or a null ShipVia'
print 'Action: 		Allow'
print 'Database: 	Northwind7 and Northwind8'
print '------------------------'
print 'Table: 		Orders'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Orders',9,'Allow'
FROM northwind7.dbo.Orders
WHERE ShipVia IS NULL
	OR ShipVia NOT IN 
	(SELECT ShipperID
	 FROM northwind7.dbo.Shippers);

--0 orders found in nw7 

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Orders',9,'Allow'
FROM northwind8.dbo.Orders
WHERE ShipVia IS NULL
	OR shipvia not in 
		(SELECT shipperid 
		 FROM northwind8.dbo.Shippers);

--2 orders found in nw8

print '=============== END RULE 09 CHECKING ===================='


print '================ BEGIN RULE 10 CHECKING =================='
print 'DQ Rule 10: 	Freight valued more than the total cost of the entire order'
print 'Action: 		Allow'
print 'Database: 	Northwind7 and Northwind8'
print '------------------------'
print 'Table: 		Orders'
print '------------------------'



INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Orders',10,'Allow'
FROM northwind7.dbo.Orders o, (
				SELECT orderid, sum((UnitPrice*Quantity)) [orderprice]
				FROM northwind7.dbo.[Order Details] od
				GROUP by od.OrderID
				) tp7
WHERE tp7.OrderID=o.OrderID and freight > orderprice;

--2 orders found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Orders',10,'Allow'
FROM northwind8.dbo.Orders o, (
				SELECT orderid, sum((UnitPrice*Quantity)) [orderprice]
				FROM northwind8.dbo.[Order Details] od
				GROUP by od.OrderID
				) tp8
WHERE tp8.OrderID=o.OrderID and freight > orderprice;

--1 order found in nw8

print '=============== END RULE 10 CHECKING ===================='


print '================ BEGIN RULE 11 CHECKING =================='
print 'DQ Rule 11: 	An order with a null ShippedDate must remain in the factOrders with TimeKey = -1'
print 'Action: 		Fix'
print 'Database: 	Northwind7 and Northwind8'
print '------------------------'
print 'Table: 		Orders'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Orders',11,'Fix'
FROM northwind7.dbo.Orders 
WHERE ShippedDate IS NULL;

--3 orders found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Orders',11,'Fix'
FROM northwind8.dbo.Orders 
WHERE ShippedDate IS NULL;

--18 orders found in nw8

print '=============== END RULE 11 CHECKING ===================='

--SELECT *
--FROM DQLOG

-- **************************************************************
-- PLEASE FILL IN NUMBERS IN THE ##### BELOW
-- **************************************************************
-- Rule no	| 	Total Logged Rows
-- **************************************************************
-- 1			0002
-- 2			0001
-- 3			0000
-- 4			0005
-- 5			0002
-- 6			0004
-- 7			0002
-- 8			0002
-- 9			0002
-- 10			0003
-- 11			0021
-- **************************************************************
-- Total Allow 	0007
-- Total Fix 	0026
-- Total Reject	0011
-- **************************************************************
