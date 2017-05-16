---------------------------------------
--My Northwind's First DW Script File
--Student ID:   ##########
--Student Name: WVF Team
---------------------------------------

--------------------------------------------------------------------------------------------------------------------
--*** IMPORTANT ***
--DO NOT remove any of the above DROP TABLE. 
--It is to make sure that every time you run this script, all existing DW tables are removed.
--------------------------------------------------------------------------------------------------------------------



/*
MS SQL Script for Creating dimTime dimension table
Time range	: 1996 -1998
For OLTP	: northwind
Output table: dimTime

Note. 
It works in SQL Server 2008.
Insert statements has to be modified for older versions.
*/
drop table Numbers_Small;
drop table Numbers_Big;
if exists (select * from sys.tables where name='dimTime')
	drop table dimTime;
go

CREATE TABLE Numbers_Small (Number INT);
INSERT INTO Numbers_Small VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

CREATE TABLE Numbers_Big (Number_Big BIGINT);
INSERT INTO Numbers_Big ( Number_Big )
SELECT thousands.number * 1000 + hundreds.number * 100 + tens.number * 10 + ones.number as number_big
FROM numbers_small thousands, numbers_small hundreds, numbers_small tens, numbers_small ones;

CREATE TABLE dimTime(
[TimeKey] [int] NOT NULL PRIMARY KEY,
[Date] [datetime] NULL,
[Day] [char](10) NULL,
[DayOfWeek] [smallint] NULL,
[DayOfMonth] [smallint] NULL,
[DayOfYear] [smallint] NULL,
[WeekOfYear] [smallint] NULL,
[Month] [char](10) NULL,
[MonthOfYear] [smallint] NULL,
[QuarterOfYear] [smallint] NULL,
[Year] [int] NULL
);
INSERT INTO dimTime(TimeKey, Date) values(-1,'9999-12-31'); -- Create dummy for a "null" date/time
INSERT INTO dimTime (TimeKey, Date)
SELECT number_big, DATEADD(day, number_big,  '1996-01-01') as Date
FROM numbers_big
WHERE DATEADD(day, number_big,  '1996-01-01') BETWEEN '1996-01-01' AND '1998-12-31'
ORDER BY number_big;

/*
INSERT INTO dimTime (TimeKey, Date)
SELECT CONVERT(INT, CONVERT(CHAR(10),DATEADD(day, number_big,  '1996-01-01'), 112)) as DateKey,
CONVERT(DATE,DATEADD(day, number_big,  '1996-01-01')) as Date
FROM numbers_big
WHERE DATEADD(day, number_big,  '1996-01-01') BETWEEN '1996-01-01' AND '1998-12-31'
ORDER BY 1;
*/

UPDATE dimTime
SET Day = DATENAME(DW, Date),
DayOfWeek = DATEPART(WEEKDAY, Date),
DayOfMonth = DAY(Date),
DayOfYear = DATEPART(DY,Date),
WeekOfYear = DATEPART(WK,Date),
Month = DATENAME(MONTH,Date),
MonthOfYear = MONTH(Date),
QuarterOfYear = DATEPART(Q, Date),
Year = YEAR(Date);
drop table Numbers_Small;
drop table Numbers_Big;

Go











print 'Drop all DW tables (except dimTime)'
DROP TABLE factOrders;
DROP TABLE dimCustomers;
DROP TABLE dimProducts;
DROP TABLE dimSuppliers;
--------------------------------------------------------------------------------------------------------------------


print '***************************************************************'
print '****** Section 1: Creating DW Tables'
print '***************************************************************'
print 'Creating dimCustomers table'
--Add statements below... IMPORTANT! A Primary key is a surrogate key and MUST BE auto-increment by using IDENTITY(1,1)
CREATE TABLE dimCustomers
(
  CustomerKey	int PRIMARY KEY identity(1,1),
  CustomerID	nchar(5) not null,
  CompanyName	nvarchar(40) not null,
  ContactName	nvarchar(30),
  ContactTitle	nvarchar(30),
  Address	nvarchar(60),
  City	nvarchar(15),
  Region	nvarchar(15),
  PostalCode	nvarchar(10),
  Country	nvarchar(15),
  Phone	nvarchar(24),
  Fax	nvarchar(24),
);

print 'Creating dimSuppliers table'
--Add statements below...IMPORTANT! A Primary key is a surrogate key and MUST BE auto-increment by using IDENTITY(1,1)
CREATE TABLE dimSuppliers
(
  SupplierKey	int PRIMARY KEY identity(1,1),
  SupplierID	int not null,
  CompanyName	nvarchar(40) not null,
  Contactname	nvarchar(30),
  ContactTitle	nvarchar(30),
  Address	nvarchar(60),
  City	nvarchar(15),
  Region	nvarchar(15),
  PostalCode	nvarchar(10),
  Country	nvarchar(15),
  Phone	nvarchar(24),
  Fax	nvarchar(24),
  Homepage	ntext,
);


print 'Creating dimProducts table'
--Add statements below... IMPORTANT! A Primary key is a surrogate key and MUST BE auto-increment by using IDENTITY(1,1)
CREATE TABLE dimProducts
(
  ProductKey	int PRIMARY KEY identity(1,1),
  ProductID	int not null,
  ProductName	nvarchar(40) not null,
  QuantityPerUnit	nvarchar(20),
  UnitPrice	money not null,
  UnitsInStock	smallint,
  UnitsOnOrder	smallint,
  ReorderLevel	smallint,
  Discontinued	bit not null,
  CategoryName	nvarchar(15) not null,
  Description	ntext,
  Picture	image,
);


print 'Creating factOrders table'
--Add statements below... IMPORTANT! A Primary key is a composite PRIMARY KEY(CustomerKey, ProductKey, OrderDateKey) and is NOT auto-increment!!
--Also make sure that you have correct FOREIGN KEYS!!
CREATE TABLE factorders
(
  ProductKey	int FOREIGN KEY references dimProducts(ProductKey),
  CustomerKey	int FOREIGN KEY references dimCustomers(CustomerKey),
  SupplierKey	int	FOREIGN KEY references dimSuppliers(SupplierKey),
  OrderDateKey	int FOREIGN KEY references dimTime(TimeKey),
  RequiredDateKey	int FOREIGN KEY references dimTime(TimeKey),
  ShippedDateKey	int	FOREIGN KEY references dimTime(TimeKey),
  OrderID	int	Not null,
  UnitPrice	money	Not null,
  Qty	smallint	Not null,
  Discount	real	Not null,
  TotalPrice	money	Not null,
  ShipperCompany	nvarchar(40)	Not null,
  ShipperPhone	nvarchar(24),
  constraint pk_factOrders PRIMARY KEY (ProductKey, CustomerKey, OrderDateKey, SupplierKey)
);


print '***************************************************************'
print '****** Section 2: Populate DW Dimension Tables (except dimTime)'
print '***************************************************************'
print 'Populating dimCustomers from northwind3'
--Add statements below... 
MERGE INTO dimCustomers dc
USING
(
  SELECT * FROM northwind3.dbo.Customers
) c ON (dc.CustomerID = c.CustomerID) -- Assume CustomerID is unique
WHEN MATCHED THEN -- if CustomerID matched, do nothing
      UPDATE SET dc.CompanyName = c.CompanyName -- Dummy update
WHEN NOT MATCHED THEN -- Otherwise, insert a new customer
      INSERT(CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
      VALUES(c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle, c.Address, c.City, C.Region, c.PostalCode, c.Country, c.Phone, c.Fax);


print 'Populating dimCustomers from northwind4'
--Add statements below... 
MERGE INTO dimCustomers dc
USING
(
  SELECT * FROM northwind4.dbo.Customers
) c ON (dc.CustomerID = c.CustomerID) -- Assume CustomerID is unique
WHEN MATCHED THEN -- if CustomerID matched, do nothing
      UPDATE SET dc.CompanyName = c.CompanyName -- Dummy update
WHEN NOT MATCHED THEN -- Otherwise, insert a new customer
      INSERT(CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
      VALUES(c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle, c.Address, c.City, C.Region, c.PostalCode, c.Country, c.Phone, c.Fax);


print 'Populating dimProducts from northwind3'
--Add statements below... 
MERGE INTO dimProducts dp
USING
(
  SELECT ProductID, ProductName,QuantityPerUnit,UnitPrice,
         UnitsInStock,UnitsOnOrder,ReorderLevel,Discontinued,
         CategoryName,Description,Picture
  FROM northwind3.dbo.Products p1, northwind3.dbo.Categories c1
  WHERE p1.CategoryID=c1.CategoryID
) pc ON (dp.ProductID = pc.ProductID) -- Assume ProductID is unique
WHEN MATCHED THEN -- if ProductID matched, do nothing
      UPDATE SET dp.ProductName = pc.ProductName -- Dummy update
WHEN NOT MATCHED THEN -- Otherwise, insert a new product
      INSERT(ProductID, ProductName, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel,
              Discontinued, CategoryName, Description, Picture)
      VALUES(pc.ProductID, pc.ProductName, pc.QuantityPerUnit, pc.UnitPrice, pc.UnitsInStock, pc.UnitsOnOrder, 
              pc.ReorderLevel, pc.Discontinued, pc.CategoryName, pc.Description, pc.Picture);


print 'Populating dimProducts from northwind4'
--Add statements below... 
MERGE INTO dimProducts dp
USING
(
  SELECT ProductID, ProductName,QuantityPerUnit,UnitPrice,
         UnitsInStock,UnitsOnOrder,ReorderLevel,Discontinued,
         CategoryName,Description,Picture
  FROM northwind4.dbo.Products p1, northwind4.dbo.Categories c1
  WHERE p1.CategoryID=c1.CategoryID
) pc ON (dp.ProductID = pc.ProductID) -- Assume ProductID is unique
WHEN MATCHED THEN -- if ProductID matched, do nothing
      UPDATE SET dp.ProductName = pc.ProductName -- Dummy update
WHEN NOT MATCHED THEN -- Otherwise, insert a new product
      INSERT(ProductID, ProductName, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, 
              Discontinued, CategoryName, Description, Picture)
      VALUES(pc.ProductID, pc.ProductName, pc.QuantityPerUnit, pc.UnitPrice, pc.UnitsInStock, pc.UnitsOnOrder, 
              pc.ReorderLevel, pc.Discontinued, pc.CategoryName, pc.Description, pc.Picture);


print 'Populating dimSuppliers from northwind3'
--Add statements below... 
MERGE INTO dimSuppliers ds
USING
(
  SELECT * FROM northwind3.dbo.Suppliers 
) s ON (ds.SupplierID = s.SupplierID) -- Assume SupplierID is unique
WHEN MATCHED THEN -- if SupplierID matched, do nothing
      UPDATE SET ds.CompanyName = s.CompanyName -- Dummy update
WHEN NOT MATCHED THEN -- Otherwise, insert a new Supplier
      INSERT(SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region,
            PostalCode, Country, Phone, Fax, HomePage)
      VALUES(s.SupplierID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region,
            s.PostalCode, s.Country, s.Phone, s.Fax, s.HomePage);


print 'Populating dimSuppliers from northwind4'
--Add statements below... 
MERGE INTO dimSuppliers ds
USING
(
  SELECT * FROM northwind4.dbo.Suppliers 
) s ON (ds.SupplierID = s.SupplierID) -- Assume SupplierID is unique
WHEN MATCHED THEN -- if SupplierID matched, do nothing
      UPDATE SET ds.CompanyName = s.CompanyName -- Dummy update
WHEN NOT MATCHED THEN -- Otherwise, insert a new Supplier
      INSERT(SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region,
              PostalCode, Country, Phone, Fax, HomePage)
      VALUES(s.SupplierID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region,
              s.PostalCode, s.Country, s.Phone, s.Fax, s.HomePage);


print '***************************************************************'
print '****** Section 3: Counting rows of OLTP and DW Tables'
print '***************************************************************'
print 'Checking Number of Rows of each table in the source databases and the DW Database'
--Add statements below for counting total numbers of records in Customers and dimCustomers
SELECT 	count(*) as[Total Customer Rows]
FROM 	dimCustomers;

SELECT 	count(*) as [Total Northwind3 Customer Rows]
FROM 	northwind3.dbo.Customers;

SELECT 	count(*) as [Total Northwind4 Customer Rows]
FROM 	northwind4.dbo.Customers;

--Add statements below for counting total numbers of records in Products and dimProducts
SELECT 	count(*) as[Total Products Rows]
FROM 	dimProducts;

SELECT 	count(*) as [Total Northwind3 Products Rows]
FROM 	northwind3.dbo.Products;

SELECT 	count(*) as [Total Northwind4 Products Rows]
FROM 	northwind4.dbo.Products;

--Add statements below for counting total numbers of records in Suppliers and dimSuppliers
SELECT 	count(*) as[Total Suppliers Rows]
FROM 	dimSuppliers;

SELECT 	count(*) as [Total Northwind3 Suppliers Rows]
FROM 	northwind3.dbo.Suppliers;

SELECT 	count(*) as [Total Northwind4 Suppliers Rows]
FROM 	northwind4.dbo.Suppliers;




-- **************************************************************
-- FILL IN THE ##### BELOW
-- **************************************************************
-- Source table		Northwind3	Northwind4	Target table 	DW	
-- **************************************************************
-- Customers 			13			78		dimCustomers	91
-- Products				77			77		dimProducts		77
-- **************************************************************



print '***************************************************************'
print 'My First Northwind Dimension tables are now completed'
print '***************************************************************'

-- ==============================================================
-- 
--   *** STOP HERE NOW *** STOP HERE NOW *** STOP HERE NOW ***
--
--          The Sections 4 and 5 below is for the next week :)
--
-- ==============================================================

print '***************************************************************'
print '****** Section 4: Populate DW Fact Table'
print '***************************************************************'
print 'Populating factOrders from northwind3'
--Add statements below... 

MERGE INTO factOrders fo 
USING
(
	SELECT ProductKey, CustomerKey, SupplierKey,
          dt1.TimeKey as [OrderDatekey], -- from dimTime
          dt2.TimeKey as [RequiredDatekey], -- from dimTime
          dt3.Timekey as [ShippedDatekey], -- from dimTime
          o.OrderID as [OrderID],od.UnitPrice as [UnitPrice],
          od.Quantity as [Qty],Discount,
          od.UnitPrice*od.Quantity as [TotalPrice], -- Calculation
          sh.CompanyName as ShipperCompany, 
          sh.Phone as ShipperPhone
  FROM northwind3.dbo.Orders o,
        northwind3.dbo.[Order Details] od,
        northwind3.dbo.Shippers sh,	
        northwind3.dbo.Suppliers s,
        northwind3.dbo.Products p,		
        dimCustomers dc, dimProducts dp, dimSuppliers ds,
        dimTime dt1, dimTime dt2, dimTime dt3 -- Three dimTime tables
  WHERE od.OrderID=o.OrderID
      AND dp.ProductID=od.ProductID
      AND o.CustomerID=dc.CustomerID
      AND s.SupplierID=ds.SupplierID
      AND dt1.Date=o.OrderDate -- Each dt1,dt2, dt3 needs join!
      AND dt2.Date=o.RequiredDate
      AND dt3.Date=o.ShippedDate
      AND o.ShipVia=sh.ShipperID
      AND p.ProductID=od.ProductID
      And s.SupplierID=p.SupplierID
) o ON (o.ProductKey = fo.ProductKey -- Assume All Keys are unique
          AND o.CustomerKey=fo.CustomerKey
          AND o.OrderDateKey=fo.OrderDateKey
          AND o.SupplierKey=fo.SupplierKey)
WHEN MATCHED THEN -- if they matched, do nothing
      UPDATE SET fo.OrderID = o.OrderID -- Dummy update
WHEN NOT MATCHED THEN -- Otherwise, insert a new row
      INSERT(ProductKey, CustomerKey, SupplierKey, OrderDateKey, RequiredDateKey, 
            ShippedDateKey, OrderID, UnitPrice, Qty, Discount, TotalPrice, ShipperCompany, ShipperPhone)
      VALUES(o.ProductKey, o.CustomerKey, o.SupplierKey, o.OrderDateKey, o.RequiredDateKey, 
            o.ShippedDateKey, o.OrderID, o.UnitPrice, o.Qty, o.Discount, o.TotalPrice, o.ShipperCompany, o.ShipperPhone);



print 'Populating factOrders from northwind4'
--Add statements below... 
MERGE INTO factOrders fo 
USING
(
	SELECT ProductKey, CustomerKey, SupplierKey,
        dt1.TimeKey as [OrderDatekey], -- from dimTime
        dt2.TimeKey as [RequiredDatekey], -- from dimTime
        dt3.Timekey as [ShippedDatekey], -- from dimTime
        o.OrderID as [OrderID],od.UnitPrice as [UnitPrice],
        od.Quantity as [Qty],Discount,
        od.UnitPrice*od.Quantity as [TotalPrice], -- Calculation
        sh.CompanyName as ShipperCompany, 
        sh.Phone as ShipperPhone
  FROM northwind4.dbo.Orders o,
      northwind4.dbo.[Order Details] od,
      northwind4.dbo.Shippers sh,	
      northwind4.dbo.Suppliers s,		
      dimCustomers dc, dimProducts dp, dimSuppliers ds,
      dimTime dt1, dimTime dt2, dimTime dt3, -- Three dimTime tables
      --northwind3.dbo.Suppliers s,
      northwind4.dbo.Products p
  WHERE od.OrderID=o.OrderID
      AND dp.ProductID=od.ProductID
      AND o.CustomerID=dc.CustomerID
      AND s.SupplierID=ds.SupplierID
      AND dt1.Date=o.OrderDate -- Each dt1,dt2, dt3 needs join!
      AND dt2.Date=o.RequiredDate
      AND dt3.Date=o.ShippedDate
      AND o.ShipVia=sh.ShipperID
      AND p.ProductID=od.ProductID
      And s.SupplierID=p.SupplierID 
) o ON (o.ProductKey = fo.ProductKey -- Assume All Keys are unique
          AND o.CustomerKey=fo.CustomerKey
          AND o.OrderDateKey=fo.OrderDateKey
          AND o.SupplierKey=fo.SupplierKey)
WHEN MATCHED THEN -- if they matched, do nothing
      UPDATE SET fo.OrderID = o.OrderID -- Dummy update
WHEN NOT MATCHED THEN -- Otherwise, insert a new row
      INSERT(ProductKey, CustomerKey, SupplierKey, OrderDateKey, RequiredDateKey, 
              ShippedDateKey, OrderID, UnitPrice, Qty, Discount, TotalPrice, ShipperCompany, ShipperPhone)
      VALUES(o.ProductKey, o.CustomerKey, o.SupplierKey, o.OrderDateKey, o.RequiredDateKey, 
              o.ShippedDateKey, o.OrderID, o.UnitPrice, o.Qty, o.Discount, o.TotalPrice, o.ShipperCompany, o.ShipperPhone);




print '***************************************************************'
print '****** Section 5: Counting rows of OLTP and DW Tables'
print '***************************************************************'
print 'Checking Number of Rows of Orders joining with Order Details and the factOrder'
--Add statements below for checking if the factOrders table contains all data 
--For Norhtwinds 1 and 2, it can be done by joining Orders with [Order Details]
SELECT 	count(distinct OrderID) as[Total Order Rows]
FROM 	factOrders;

SELECT 	count(*) as [Total Northwind3 Orders Rows]
FROM 	northwind3.dbo.Orders;


SELECT 	count(*) as [Total Northwind4 Orders Rows]
FROM 	 northwind4.dbo.Orders;
-- ***************************************************************************
-- FILL IN THE ##### BELOW
-- ***************************************************************************
-- Source table					Northwind1	Northwind2	Target table 	DW	
-- ***************************************************************************
-- Orders join [Order Details] 		122			808		factOrders		707
-- ***************************************************************************

print '***************************************************************'
print 'My First Northwind DW creation is now completed'
print '***************************************************************'
