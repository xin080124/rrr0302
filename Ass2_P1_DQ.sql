-------------------------------------------------------
--Data Warehousing Assignment 2 - Phase 1
--Data Quality Checking and Logging for Data Warehouse
--Check For DW: 	My Northwind DW
--Student ID:   	
--Student Name: 	
-------------------------------------------------------

print '***************************************************************'
print '****** Section 1: DQLog table'
print '***************************************************************'
--SQL statements to DROP and CREATE a DQLog table
--DROP TABLE DQLog;
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
print 'DQ Rule 01: 	Unit Price is negative or null'
print 'Action: 		Reject'
print 'Database: 	Northwind7 and northwind8'
print '------------------------'
print 'Table: 		Products'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Products',1,'Reject'
FROM northwind7.dbo.Products
WHERE UnitPrice < 0 or UnitPrice is null

--2 pruducts found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Products',1,'Reject'
FROM northwind8.dbo.Products
WHERE UnitPrice < 0 or UnitPrice is null

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
WHERE Quantity < 0 or UnitPrice is null

--1 order found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Order Details',2,'Reject'
FROM northwind8.dbo.[Order Details]
WHERE Quantity < 0 or UnitPrice is null

--0 order found in nw8

print '=============== END RULE 02 CHECKING ===================='


print '================ BEGIN RULE 03 CHECKING =================='
print 'DQ Rule 03: 	Discount > 70% (0.7) on a product that has UnitPrice
greater than $400'
print 'Action: 		Allow'
print 'Database: 	Northwind7 and northwind8'
print '------------------------'
print 'Table: 		Order Details'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Order Detail',3,'Allow'
FROM northwind7.dbo.[Order Details]
WHERE UnitPrice > 400 and Discount > 0.7

--0 order found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Order Detail',3,'Allow'
FROM northwind8.dbo.[Order Details]
WHERE UnitPrice > 400 and Discount > 0.7

--0 order found in nw8

print '=============== END RULE 03 CHECKING ===================='


print '================ BEGIN RULE 04 CHECKING =================='
print 'DQ Rule 04: 	Customer with wrong Country format'
print 'Action: 		Fix'
print 'Database: 	Customers and Suppliers'
print '------------------------'
print 'Table: 		Northwind7 and northwind8'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Customers',4,'Fix'
FROM northwind7.dbo.customers
WHERE country in ('us', 'united states', 'britain', 'united kingdom')

--2 customers found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Suppliers',4,'Fix'
FROM northwind7.dbo.Suppliers
WHERE country in ('us', 'united states', 'britain', 'united kingdom')

--1 supplier found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Customers',4,'Fix'
FROM northwind8.dbo.customers
WHERE country in ('us', 'united states', 'britain', 'united kingdom')

--2 customers found in nw8

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Suppliers',4,'Fix'
FROM northwind8.dbo.Suppliers
WHERE country in ('us', 'united states', 'britain', 'united kingdom')

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
WHERE len(postalcode) != 5

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
WHERE categoryid  not in (select categoryid from northwind7.dbo.Categories) or CategoryID is null
or SupplierID  not in (select SupplierID from northwind7.dbo.Suppliers) or SupplierID is null

--2 products found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Products',6,'Reject'
FROM northwind8.dbo.Products
WHERE categoryid  not in (select categoryid from northwind7.dbo.Categories) or CategoryID is null
or SupplierID  not in (select SupplierID from northwind7.dbo.Suppliers) or SupplierID is null

--2 products found in nw8

print '=============== END RULE 06 CHECKING ===================='


print '================ BEGIN RULE 07 CHECKING =================='
print 'DQ Rule 07: 	ProductID doesn��t exist or is null'
print 'Action: 		Reject'
print 'Database: 	Northwind7 and northwind8'
print '------------------------'
print 'Table: 		Order Details'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Order Details',7,'Reject'
FROM northwind7.dbo.[Order Details]
WHERE ProductID  not in (select ProductID from northwind7.dbo.Products) or ProductID is null

--0 order found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Order Details',7,'Reject'
FROM northwind8.dbo.[Order Details]
WHERE ProductID  not in (select ProductID from northwind8.dbo.Products) or ProductID is null

--2 orders found in nw8

print '=============== END RULE 07 CHECKING ===================='


print '================ BEGIN RULE 08 CHECKING =================='
print 'DQ Rule 08: 	(CustomerID doesn��t exist or is null) and (both ShipAddress and ShipCity are null)'
print 'Action: 		Allow'
print 'Database: 	Northwind7 and Northwind8'
print '------------------------'
print 'Table: 		Orders'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Orders',8,'Reject'
FROM northwind7.dbo.Orders
WHERE (CustomerID  not in (select CustomerID from northwind7.dbo.Customers) or CustomerID is null)
and (ShipAddress is null and ShipCity is null)

--0 order found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Orders',8,'Reject'
FROM northwind8.dbo.Orders
WHERE (CustomerID  not in (select CustomerID from northwind8.dbo.Customers) or CustomerID is null)
and (ShipAddress is null and ShipCity is null)

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
WHERE shipvia not in (select shipperid from northwind7.dbo.Shippers) or shipvia is null

--2 orders found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Orders',9,'Allow'
FROM northwind8.dbo.Orders
WHERE shipvia not in (select shipperid from northwind8.dbo.Shippers) or shipvia is null

--2 orders found in nw8

print '=============== END RULE 09 CHECKING ===================='


print '================ BEGIN RULE 10 CHECKING =================='
print 'DQ Rule 10: 	a Freight valued more than the total cost of the entire order'
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
								group by od.OrderID
								) tp7
WHERE tp7.OrderID=o.OrderID and freight > orderprice

--2 orders found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Orders',10,'Allow'
FROM northwind8.dbo.Orders o, (
								SELECT orderid, sum((UnitPrice*Quantity)) [orderprice]
								FROM northwind8.dbo.[Order Details] od
								group by od.OrderID
								) tp8
WHERE tp8.OrderID=o.OrderID and freight > orderprice

--1 order found in nw8

print '=============== END RULE 10 CHECKING ===================='


print '================ BEGIN RULE 11 CHECKING =================='
print 'DQ Rule 11: 	An order with a null ShippedDate must remain in the factOrders with TimeKey = -1'
print 'Action: 		Fix'
print 'Database: 	Northwind7 and Northwind8'
print '------------------------'
print 'Table: 		orders'
print '------------------------'

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind7','Orders',11,'Fix'
FROM northwind7.dbo.Orders 
WHERE ShippedDate is null 

--3 orders found in nw7

INSERT INTO DQLog(RowID, DBName, TableName, RuleNo, Action)
SELECT %%physloc%%, 'northwind8','Orders',11,'Fix'
FROM northwind8.dbo.Orders 
WHERE ShippedDate is null 

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
-- 11           0021
-- **************************************************************
-- Total Allow 	0009
-- Total Fix 	0026
-- Total Reject	0009
-- **************************************************************
