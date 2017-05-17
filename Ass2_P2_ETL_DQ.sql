---------------------------------------
--Data Warehousing Assignment 2 - Phase 2
--My Northwind's DW ETL+DQ Script File
--Student ID:   	
--Student Name: 	

------------------------------------

print '***************************************************************'
print '****** Section 1: Creating DW Tables'
print '***************************************************************'

print 'Drop all DW tables (except dimTime)'
--drop all DW tables except dimTime

--drop table factOrders;
drop table dimCustomers;
drop table dimProducts;
drop table dimSuppliers;
--drop table BufferOrder7;
--drop table BufferOrder8

print 'Creating all dimension tables required'

print 'Creating dimCustomers table'
--creating dimcustomers
create table dimCustomers(
	CustomerKey	int	identity(1, 1)  primary key,
	CustomerID	nchar(5)	not null,
	CompanyName	nvarchar(40)	not null,
	ContactName	nvarchar(30),
	ContactTitle	nvarchar(30),	
	Address	nvarchar(60),
	City	nvarchar(15),
	Region	nvarchar(15),
	PostalCode	nvarchar(10),	
	Country	nvarchar(15),
	Phone	nvarchar(24),
	Fax	nvarchar(24)	
);

print 'Creating dimProducts table'
--creating dimproducts
create table dimProducts(
	ProductKey	int identity(1, 1) primary key,
	ProductID	int	not null,
	ProductName	nvarchar(40)	not null,
	QuantityPerUnit	nvarchar(20),
	UnitPrice	money,
	UnitsInStock	smallint,
	UnitsOnOrder	smallint,
	ReorderLevel	smallint,
	Discontinued	bit,
	CategoryName	nvarchar(15),	
	Description	ntext,
	Picture	image	
);

print 'Creating dimSuppliers table'
--creating dimsuppliers
create table dimSuppliers(
	SupplierKey	int identity(1, 1)	primary key,
	SupplierID	int	not null,
	CompanyName	nvarchar(40)	not null,
	ContactName	nvarchar(30),
	ContactTitle	nvarchar(30),	
	Address	nvarchar(60),
	City	nvarchar(15),
	Region	nvarchar(15),
	PostalCode	nvarchar(10),	
	Country	nvarchar(15),
	Phone	nvarchar(24),
	Fax	nvarchar(24),
	HomePage	ntext	
);


print 'Creating a fact table required'
--creating fact table
create table factOrders(
	ProductKey	int	foreign key references dimProducts(ProductKey),
	CustomerKey	int	foreign key references dimCustomers(CustomerKey),
	SupplierKey	int	foreign key references dimSuppliers(SupplierKey),
	OrderDateKey	int	foreign key references dimTime(TimeKey),
	RequiredDateKey	int	foreign key references dimTime(TimeKey),
	ShippedDateKey	int	foreign key references dimTime(TimeKey),
	OrderID	int	not null,
	UnitPrice	money,
	Qty	smallint,
	Discount	real,
	TotalPrice	money,
	ShipperCompany	nvarchar(40)	not null,
	ShipperPhone	nvarchar(24),
	primary key(ProductKey, CustomerKey, SupplierKey, OrderDateKey)
);


print '***************************************************************'
print '****** Section 2: Populate DW Dimension Tables (except dimTime)'
print '***************************************************************'

print 'Populating all dimension tables from northwind7 and northwind8'

print 'populating dimProducts from nw7'

--Populate dimProducts table from northwind7
--rule 1,6 involve, both reject
merge into dimProducts dp
using(
	select p.ProductID, p.ProductName, p.QuantityPerUnit, p.UnitPrice, p.UnitsInStock, p.UnitsOnOrder, 
	p.ReorderLevel, p.Discontinued, c.CategoryName, c.Description, c.Picture
	from northwind7.dbo.Products p, northwind7.dbo.Categories c
	where p.CategoryID = c.CategoryID and p.%%physloc%% not in 
			(
			select rowid from dqlog where dbname = 'northwind7' and tablename = 'Products' and 
			(ruleno =1 or ruleno = 6) and action = 'Reject' --apply rule 1 and 6
			)
	)pc on dp.ProductID = pc.ProductID
when not matched then
insert (ProductID, ProductName, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, 
Discontinued, CategoryName, Description, Picture)
values (pc.ProductID, pc.ProductName, pc.QuantityPerUnit, pc.UnitPrice, pc.UnitsInStock, pc.UnitsOnOrder,
 pc.ReorderLevel, pc.Discontinued, pc.CategoryName, pc.Description, pc.Picture);
print '
populating dimProducts from nw8'
--Populate dimProducts table from northwind8
--rule 1,6 involve, both reject
merge into dimProducts dp
using(
	select p.ProductID, p.ProductName, p.QuantityPerUnit, p.UnitPrice, p.UnitsInStock, p.UnitsOnOrder, 
	p.ReorderLevel, p.Discontinued, c.CategoryName, c.Description, c.Picture
	from northwind8.dbo.Products p, northwind8.dbo.Categories c
	where p.CategoryID = c.CategoryID and p.%%physloc%% not in 
		(
	select rowid from dqlog where dbname = 'northwind8' and tablename = 'Products' and (ruleno =1 or ruleno = 6)
	 and action = 'Reject' --apply rule 1 and 6
			)
)pc on dp.ProductID = pc.ProductID
when not matched then
insert (ProductID, ProductName, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued,
		   CategoryName, Description, Picture)
values (pc.ProductID, pc.ProductName, pc.QuantityPerUnit, pc.UnitPrice, pc.UnitsInStock, pc.UnitsOnOrder, pc.ReorderLevel, 
pc.Discontinued, pc.CategoryName, pc.Description, pc.Picture);
-- populating dimProducts done

print '
populating dimCustomers from nw7 with none-fixed record'
--Populate dimCustomers table from northwind7
--rule 4, fix
merge into dimCustomers dc
using(
	select * from northwind7.dbo.Customers c
	where	c.%%physloc%% NOT IN 	-- Use NOT IN to exclude all Customers who need a fix
	(
		select 	RowID 	 	 		
		from 	DQLog
		where 	DBName='northwind7' AND TableName='Customers' AND RuleNo=4 AND Action='Fix' 
	)
)c on dc.CustomerID = c.CustomerID
when matched then
update set dc.CompanyName = c.CompanyName
when not matched then
insert (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
values (c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle, c.Address, c.City, c.Region, c.PostalCode, c.Country, 
c.Phone, c.Fax);

print '
populating dimCustomers from nw7 with fixed record'
merge into dimCustomers dc
using
(
select * from northwind7.dbo.Customers c
where	c.%%physloc%%  IN 	--fix the customers'country format
	(
		select 	RowID 	 	 		
		from 	DQLog
		where 	DBName='northwind7' AND TableName='Customers' AND RuleNo=4 AND Action='Fix' 
	)
) c on (dc.CustomerID = c.CustomerID) 
when matched then
update set dc.CompanyName = c.CompanyName
when not matched then 
insert (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
values (c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle, c.Address, c.City, c.Region, c.PostalCode, 'USA', 
c.Phone, c.Fax);

print '
populating dimCustomers from nw8 with none-fixed record'
--Populate dimCustomers table from northwind8
--rule 4, fix
merge into dimCustomers dc
using(
	select * from northwind8.dbo.Customers c
	where	c.%%physloc%% NOT IN 	-- Use NOT IN to exclude all Customers who need a fix
	(
		select 	RowID 	 	 		
		from 	DQLog
		where 	DBName='northwind8' and TableName='Customers' and RuleNo=4 and Action='Fix' 
	)
)c on dc.CustomerID = c.CustomerID
when matched then
update set dc.CompanyName = c.CompanyName
when not matched then
insert (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
values (c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle, c.Address, c.City, C.Region, c.PostalCode, c.Country, 
c.Phone, c.Fax);

print '
populating dimCustomers from nw8 with fixed record'
merge into dimCustomers dc
using
(
select * from northwind8.dbo.Customers c
where	c.%%physloc%%  IN 	--fix the customers'country format
	(
		select 	RowID 	 	 		
		from 	DQLog
		where 	DBName='northwind8' and TableName='Customers' and RuleNo=4 and Action='Fix' 
	)
) c on (dc.CustomerID = c.CustomerID) 
when matched then
update set dc.CompanyName = c.CompanyName
when not matched then 
insert(CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
values(c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle, c.Address, c.City, c.Region, c.PostalCode, 'UK', 
c.Phone, c.Fax);
--populating dimcustomers done

print '
populating dimSuppliers from nw7 with none-fixed record'
--Populate dimSuppliers table from northwind7
merge into dimSuppliers ds
using(
	select * from northwind7.dbo.Suppliers s
	where	s.%%physloc%% not in  	-- Use NOT IN to exclude all Suppliers who need a fix
	(
		select 	RowID 	 	 		
		from 	DQLog
		where 	DBName='northwind7' and TableName='Suppliers' and RuleNo=4 and Action='Fix' 
	)
)s on ds.SupplierID = s.SupplierID
when matched then 
update set ds.companyname =s.companyname
when not matched then
insert (SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, HomePage)
values (s.SupplierID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region, s.PostalCode, s.Country, 
s.Phone, s.Fax, s.HomePage);

print '
populating dimSuppliers from nw7 with fixed record'
merge into dimSuppliers ds
using(
	select * from northwind7.dbo.Suppliers s
	where	s.%%physloc%% IN 	-- fix suppliers'format
	(
		select 	RowID 	 	 		
		from 	DQLog
		where 	DBName='northwind7' and TableName='Suppliers' and RuleNo=4 and Action='Fix' 
	)
)s on ds.SupplierID = s.SupplierID
when matched then 
update set ds.companyname =s.companyname
when not matched then
insert (SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, 
Fax, HomePage)
values (s.SupplierID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region, s.PostalCode, 'USA', 
s.Phone, s.Fax, s.HomePage);

print '
populating dimSuppliers from nw8 with none-fixed record'
--Populate dimSuppliers table from northwind8
merge into dimSuppliers ds
using(
	select * from northwind8.dbo.Suppliers s
	where	s.%%physloc%% NOT IN 	-- Use NOT IN to exclude all Suppliers who need a fix
	(
		select 	RowID 	 	 		
		from 	DQLog
		where 	DBName='northwind8' and TableName='Suppliers' and RuleNo=4 and Action='Fix' 
	)
)s on ds.SupplierID = s.SupplierID
when matched then 
update set ds.companyname =s.companyname
when not matched then
insert (SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, 
Fax, HomePage)
values (s.SupplierID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region, s.PostalCode, 
s.Country, s.Phone, s.Fax, s.HomePage);

print '
populating dimSuppliers from nw8 with fixed record'
merge into dimSuppliers ds
using(
	select * from northwind8.dbo.Suppliers s
	where	s.%%physloc%% IN 	-- fix suppliers'format
	(
		select 	RowID 	 	 		
		from 	DQLog
		where 	DBName='northwind8' and TableName='Suppliers' and RuleNo=4 and Action='Fix' 
	)
)s on ds.SupplierID = s.SupplierID
when matched then 
update set ds.companyname =s.companyname
when not matched then
insert (SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, 
Fax, HomePage)
values (s.SupplierID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region, s.PostalCode,
 'UK', s.Phone, s.Fax, s.HomePage);
--populating dimSuppliers done


print '***************************************************************'
print '****** Section 3: Populate DW Fact Tables'
print '***************************************************************'

print 'Populating the fact table from northwind7 and northwind8'

--create the staging table first, same as orders table
--create staging table for nw7
create table BufferOrder7
(
	OrderID		int		primary key not null,
	CustomerID  nchar(5),
	OrderDate datetime,
	RequiredDate datetime,
	ShippedDate datetime,
	ShipVia int,
	Freight money,
	ShipName nvarchar(40),
	ShipAddress nvarchar(60),
	ShipCity nvarchar(15),
	ShipRegion nvarchar(15),
	ShipPostalCode nvarchar(10),
	ShipCountry nvarchar(15)
)
--transfer data
insert into BufferOrder7
(OrderID, CustomerID, OrderDate, Requireddate,ShippedDate,Freight,ShipName,ShipAddress,ShipCity ,ShipRegion,
ShipPostalCode,ShipCountry,ShipVia)
select OrderID, CustomerID,Orderdate, Requireddate, isnull(ShippedDate, '9999-12-31'),Freight,ShipName,
ShipAddress,ShipCity ,ShipRegion,ShipPostalCode,ShipCountry,ShipVia
from northwind7.dbo.Orders

--create staging table for nw8
create table BufferOrder8
(
	OrderID		int		primary key not null,
	CustomerID  nchar(5),
	OrderDate datetime,
	RequiredDate datetime,
	ShippedDate datetime,
	ShipVia int,
	Freight money,
	ShipName nvarchar(40),
	ShipAddress nvarchar(60),
	ShipCity nvarchar(15),
	ShipRegion nvarchar(15),
	ShipPostalCode nvarchar(10),
	ShipCountry nvarchar(15)
)
--transfer data
insert into BufferOrder8
(OrderID, CustomerID, OrderDate, Requireddate,ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, 
ShipRegion,ShipPostalCode,ShipCountry)
select OrderID, CustomerID,Orderdate, RequiredDate, isnull(ShippedDate, '9999-12-31'), 
ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
from northwind8.dbo.Orders



--Populate factOrders table from northwind7
merge into factOrders fo
using(
	select dp.ProductKey, dc.CustomerKey, ds.SupplierKey, dt1.TimeKey as 'OrderDateKey', 
	dt2.TimeKey as 'RequiredDateKey', dt3.TimeKey as 'ShippedDateKey', o.OrderID, od.UnitPrice, od.Quantity as 'Qty', 
	od.Discount, od.UnitPrice * od.Quantity as 'TotalPrice', sh.CompanyName as 'ShipperCompany', sh.Phone as 'ShipperPhone'
	from   dimCustomers dc, dimProducts dp, dimSuppliers ds, dimTime dt1, dimTime dt2, dimTime dt3,
		   bufferorder7 o, northwind7.dbo.[Order Details] od, northwind7.dbo.Shippers sh, northwind7.dbo.Products p, 
		   northwind7.dbo.Suppliers s
	where  dc.CustomerID = o.CustomerID
		   and dp.ProductID = od.ProductID
		   and ds.SupplierID = s.SupplierID
		   and s.SupplierID = p.SupplierID
		   and p.ProductID = od.ProductID
		   and dt1.date = o.OrderDate
		   and dt2.date = o.RequiredDate
		   and dt3.date = o.ShippedDate
		   and o.OrderID = od.OrderID
		   and o.ShipVia = sh.ShipperID
		   and od.%%physloc%% NOT IN 		
		(
			select 	RowID	 	
			from 	DQLog
			where 	DBName='northwind7' and TableName='Order Details' and (RuleNo = 2 or RuleNo = 7)and Action='Reject' 
		)
			and o.shippeddate != '9999-12-31'
			
)ft on (
	fo.ProductKey = ft.ProductKey
	and fo.CustomerKey = ft.CustomerKey
	and fo.SupplierKey = ft.SupplierKey
	and fo.OrderDateKey = ft.OrderDateKey
	)
when matched then
update set fo.orderid = ft.orderid
when not matched then
insert (ProductKey, CustomerKey, SupplierKey, OrderDateKey, RequiredDateKey, ShippedDateKey,
		OrderID, UnitPrice, Qty, Discount, TotalPrice, ShipperCompany, ShipperPhone
	)
values (ft.ProductKey, ft.CustomerKey, ft.SupplierKey, ft.OrderDateKey, ft.RequiredDateKey, ft.ShippedDateKey,
		   ft.OrderID, ft.UnitPrice, ft.Qty, ft.Discount, ft.TotalPrice, ft.ShipperCompany, ft.ShipperPhone
	);

--Fix the shippedDate
merge into factOrders fo
using(
	select dp.ProductKey, dc.CustomerKey, ds.SupplierKey, dt1.TimeKey as 'OrderDateKey', dt2.TimeKey as 'RequiredDateKey',
	 dt3.TimeKey as 'ShippedDateKey', o.OrderID, od.UnitPrice, od.Quantity as 'Qty', od.Discount, od.UnitPrice * od.Quantity as 
	 'TotalPrice', sh.CompanyName as 'ShipperCompany', sh.Phone as 'ShipperPhone'
	 from   dimCustomers dc, dimProducts dp, dimSuppliers ds, dimTime dt1, dimTime dt2, dimTime dt3,
		   bufferorder7 o, northwind7.dbo.[Order Details] od, northwind7.dbo.Shippers sh, northwind7.dbo.Products p,
		    northwind7.dbo.Suppliers s
	where  dc.CustomerID = o.CustomerID
		   and dp.ProductID = od.ProductID
		   and ds.SupplierID = s.SupplierID
		   and s.SupplierID = p.SupplierID
		   and p.ProductID = od.ProductID
		   and dt1.date = o.OrderDate
		   and dt2.date = o.RequiredDate
		   and dt3.date = o.ShippedDate
		   and o.OrderID = od.OrderID
		   and o.ShipVia = sh.ShipperID
		   and o.shippeddate = '9999-12-31'
)ft on (
	fo.ProductKey = ft.ProductKey
	and fo.CustomerKey = ft.CustomerKey
	and fo.SupplierKey = ft.SupplierKey
	and fo.OrderDateKey = ft.OrderDateKey
	)
when matched then
update set fo.orderid = ft.orderid
when not matched then
insert (ProductKey, CustomerKey, SupplierKey, OrderDateKey, RequiredDateKey, ShippedDateKey,
		OrderID, UnitPrice, Qty, Discount, TotalPrice, ShipperCompany, ShipperPhone
	)
values (ft.ProductKey, ft.CustomerKey, ft.SupplierKey, ft.OrderDateKey, ft.RequiredDateKey, '-1',
		   ft.OrderID, ft.UnitPrice, ft.Qty, ft.Discount, ft.TotalPrice, ft.ShipperCompany, ft.ShipperPhone
	);

--Populate factOrders table from northwind8
merge into factOrders fo
using(
	select dp.ProductKey, dc.CustomerKey, ds.SupplierKey, dt1.TimeKey as 'OrderDateKey', dt2.TimeKey as 'RequiredDateKey',
	 dt3.TimeKey as 'ShippedDateKey', o.OrderID, od.UnitPrice, od.Quantity as 'Qty', od.Discount, 
	 od.UnitPrice * od.Quantity as 'TotalPrice', sh.CompanyName as 'ShipperCompany', sh.Phone as 'ShipperPhone'
	from   dimCustomers dc, dimProducts dp, dimSuppliers ds, dimTime dt1, dimTime dt2, dimTime dt3,
		   bufferorder8 o, northwind8.dbo.[Order Details] od, northwind8.dbo.Shippers sh, northwind8.dbo.Products p,
		    northwind8.dbo.Suppliers s
	where  dc.CustomerID = o.CustomerID
		   and dp.ProductID = od.ProductID
		   and ds.SupplierID = s.SupplierID
		   and s.SupplierID = p.SupplierID
		   and p.ProductID = od.ProductID
		   and dt1.date = o.OrderDate
		   and dt2.date = o.RequiredDate
		   and dt3.date = o.ShippedDate
		   and o.OrderID = od.OrderID
		   and o.ShipVia = sh.ShipperID
		   and od.%%physloc%% NOT IN 		
		(
			select 	RowID	 	
			from 	DQLog
			where 	DBName='northwind8' and TableName='Order Details' and (RuleNo = 2 or RuleNo = 7) and Action='Reject' 
		)
			and o.shippeddate != '9999-12-31'
)ft on (
	fo.ProductKey = ft.ProductKey
	and fo.CustomerKey = ft.CustomerKey
	and fo.SupplierKey = ft.SupplierKey
	and fo.OrderDateKey = ft.OrderDateKey
	)
when matched then
update set fo.orderid = ft.orderid
when not matched then
insert (ProductKey, CustomerKey, SupplierKey, OrderDateKey, RequiredDateKey, ShippedDateKey,
		OrderID, UnitPrice, Qty, Discount, TotalPrice, ShipperCompany, ShipperPhone
	)
values (ft.ProductKey, ft.CustomerKey, ft.SupplierKey, ft.OrderDateKey, ft.RequiredDateKey, ft.ShippedDateKey,
		   ft.OrderID, ft.UnitPrice, ft.Qty, ft.Discount, ft.TotalPrice, ft.ShipperCompany, ft.ShipperPhone
	);


--Fix the shippedDate
merge into factOrders fo
using(
	select dp.ProductKey, dc.CustomerKey, ds.SupplierKey, dt1.TimeKey as 'OrderDateKey', dt2.TimeKey as 'RequiredDateKey',
	 dt3.TimeKey as 'ShippedDateKey', o.OrderID, od.UnitPrice, od.Quantity as 'Qty', od.Discount, 
	 od.UnitPrice * od.Quantity as 'TotalPrice', sh.CompanyName as 'ShipperCompany', sh.Phone as 'ShipperPhone'
	from   dimCustomers dc, dimProducts dp, dimSuppliers ds, dimTime dt1, dimTime dt2, dimTime dt3,
		   bufferorder8 o, northwind8.dbo.[Order Details] od, northwind8.dbo.Shippers sh, northwind8.dbo.Products p, 
		   northwind8.dbo.Suppliers s
	where  dc.CustomerID = o.CustomerID
		   and dp.ProductID = od.ProductID
		   and ds.SupplierID = s.SupplierID
		   and s.SupplierID = p.SupplierID
		   and p.ProductID = od.ProductID
		   and dt1.date = o.OrderDate
		   and dt2.date = o.RequiredDate
		   and dt3.date = o.ShippedDate
		   and o.OrderID = od.OrderID
		   and o.ShipVia = sh.ShipperID		
		   and o.shippeddate = '9999-12-31'
)ft on (
	fo.ProductKey = ft.ProductKey
	and fo.CustomerKey = ft.CustomerKey
	and fo.SupplierKey = ft.SupplierKey
	and fo.OrderDateKey = ft.OrderDateKey
	)
when matched then
update set fo.orderid = ft.orderid
when not matched then
insert (ProductKey, CustomerKey, SupplierKey, OrderDateKey, RequiredDateKey, ShippedDateKey,
		OrderID, UnitPrice, Qty, Discount, TotalPrice, ShipperCompany, ShipperPhone
	)
values (ft.ProductKey, ft.CustomerKey, ft.SupplierKey, ft.OrderDateKey, ft.RequiredDateKey, '-1',
		   ft.OrderID, ft.UnitPrice, ft.Qty, ft.Discount, ft.TotalPrice, ft.ShipperCompany, ft.ShipperPhone
	);


print '***************************************************************'
print '****** Section 4: Counting rows of OLTP and DW Tables'
print '***************************************************************'
print 'Checking Number of Rows of each table in the source databases and the DW Database'
-- Write SQL queries to get answers to fill in the information below
--check number of rows in dimCustomers 
select count(*) as 'Customers in Northwind7' from northwind7.dbo.Customers;
select count(*) as 'Customers in Northwind8' from northwind8.dbo.Customers;
select count(*) as 'Customers in DW' from dimCustomers;
--check number of rows in dimProducts is correct
select count(*) as 'Products in Northwind7' from northwind7.dbo.Products;
select count(*) as 'Products in Northwind8' from northwind8.dbo.Products;
select count(*) as 'Products in DW' from dimProducts;
--check number of rows in dimSuppliers
select count(*) as 'Suppliers in Northwind7' from northwind7.dbo.Suppliers;
select count(*) as 'Suppliers in Northwind8' from northwind8.dbo.Suppliers;
select count(*) as 'Suppliers in DW' from dimSuppliers;
--check number of rows in factOrders is correct
select count(*) as 'OrderDetails in Northwind7' from northwind7.dbo.Orders o, northwind7.dbo.[Order Details] od
 where o.OrderID = od.OrderID;
select count(*) as 'OrderDetails in Northwind8' from northwind8.dbo.Orders o, northwind8.dbo.[Order Details] od
 where o.OrderID = od.OrderID;
select count(*) as 'OrderDetails in DW' from factOrders;

-- ****************************************************************************
-- FILL IN THE ##### 
-- ****************************************************************************
-- Source table					Northwind7	Northwind8	Target table 	DW	
-- ****************************************************************************
-- Customers					00013		00078		dimCustomers	00091
-- Products						00077		00077		dimProducts		00076
-- Suppliers					00029		00029		dimSuppliers	00029
-- Orders join [Order Details] 	00352		01801		factorders		02096
-- ****************************************************************************

print '***************************************************************'
print '****** Section 5: Validating DW Data'
print '***************************************************************'
print 'B: Validating Data in the fact table'

select OrderID
from factOrders 
where orderid NOT in
(
select OrderID
from   northwind7.dbo.orders o
where  o.%%physloc%%  NOT IN 		
		(
			select 	RowID	 	
			from 	DQLog
			where 	DBName='northwind7' and TableName='Orders' and Action='Reject' 
		)  
union
select OrderID
from   northwind8.dbo.orders o
where  o.%%physloc%%  NOT IN 		
		(
			select 	RowID	 	
			from 	DQLog
			where 	DBName='northwind8' and TableName='Orders' and Action='Reject' 
		)
)
--No OrderID found, none order missing

print '***************************************************************'
print 'My Northwind DW creation with data quality assurance is now completed'
print '***************************************************************'