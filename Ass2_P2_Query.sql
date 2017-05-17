---------------------------------------
--Data Warehousing Assignment 2 - Phase 2
--OLAP Query Script File
--Student ID:   	
--Student Name: 	
------------------------------------


print '***************************************************************'
print '****** Q.1: Query 1'
print '***************************************************************'
--List years (of OrderDate) and the sum of Total Price (displayed as Sales Revenue) for each year.

select dt.Year, sum (TotalPrice) as 'Sales Revenue'
from factOrders fo, dimTime dt
where fo.OrderDateKey=dt.TimeKey  
group by dt.Year
order by Year

print '***************************************************************'
print '****** Q.2: Query 2'
print '***************************************************************'
--List Category, Year (of OrderDate), and the sum of Total Price (displayed as Sales Revenue) of each product category in each year 
--for a product purchased by customers who only live in USA. The result is ordered by Category and Year.

select dp.CategoryName as Category,Year,sum (TotalPrice) as 'Sales Revenue'
from factOrders fo, dimTime dt, dimProducts dp,dimcustomers dc
where fo.OrderDateKey=dt.TimeKey and dc.customerkey = fo.customerkey and dp.productkey = fo.productkey and dc.Country = 'USA'
group by dp.CategoryName, year
order by dp.CategoryName, year

print '***************************************************************'
print '****** Q.3: Query 3'
print '***************************************************************'
--List countries, regions, and the sum of Total Price (displayed as Sales Revenue) of orders purchased in year 1996 
--for customers who live in each region of each country. Your result should be alphabetically ordered by Country and Region.

select dc.Country,dc.Region, sum (TotalPrice) as 'Sales Revenue'
from factOrders fo, dimTime dt, dimcustomers dc
where fo.OrderDateKey=dt.TimeKey and dc.customerkey = fo.customerkey and year = 1996
group by dc.Country,dc.Region
order by dc.Country,dc.Region


print '***************************************************************'
print '****** Q.4: Query 4'
print '***************************************************************'
--List countries, their best-selling product, and the sum of Total Price (displayed asSales Revenue). 
--Your result should be alphabetically ordered by Country and Product Name.

--create view topprice as
--select  dp.ProductName, sum (fo.UnitPrice*fo.qty) tp, dc.Country
--from factOrders fo, dimProducts dp, dimCustomers dc
--where fo.ProductKey = dp.ProductKey and dc.CustomerKey = fo.CustomerKey
--group by dp.ProductName, dc.Country


select distinct Country,ProductName,tp as [Sales Revenue]
from topprice
where tp in (select max(tp) from topprice group by Country)  

--drop view topprice