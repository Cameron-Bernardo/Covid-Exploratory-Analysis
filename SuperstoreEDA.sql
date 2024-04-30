-- Exploratory Data Analysis Project
-- Dataset: Superstore Retail Data (2020)

select TOP 1000 *
from PortfolioProject..Superstore

-- Updating the data to add separate columns for day, month, and year based off the order date

-- Updating to add the day of the week

select order_date, datename(weekday, order_date)
from PortfolioProject..Superstore

alter table Superstore
add OrderDateDay varchar(10)

update Superstore
set OrderDateDay = datename(weekday, order_date)

-- Updating to add the month

select order_date, datename(MONTH, order_date)
from PortfolioProject..Superstore

alter table Superstore
add OrderDateMonth varchar(10)

update Superstore
set OrderDateMonth = datename(MONTH, order_date)

-- Updating the to add the year

select order_date, datename(YEAR, order_date)
from PortfolioProject..Superstore

alter table Superstore
add OrderDateYear smallint

update Superstore
set OrderDateYear = datename(YEAR, order_date)

---Exploratory Data Analysis (EDA)---

--General Questions--

-- How many distinct states are there?
select count(distinct state) as NumStates
from PortfolioProject..Superstore

-- How many years does the dataset span?
select count(distinct OrderDateYear) as NumYears
from PortfolioProject..Superstore

-- How many distinct cities are there?
select count(distinct city) as NumCities
from PortfolioProject..Superstore


---Product Analysis---


-- How many distinct product categories and sub-categories are there?
select count(distinct category) as NumCategories, count(distinct Sub_Category) as NumSubCategories
from PortfolioProject..Superstore

-- Which product category and sub-category had the highest revenue?
select category, Sub_Category, round(sum(sales),2) as Revenue
from PortfolioProject..Superstore
group by Category, Sub_Category
order by 3 desc

-- Which products had the highest revenue?
select count(product_name) as NumPurchases, Product_Name, round(sum(sales),2) as Revenue
from PortfolioProject..Superstore
--where Product_Name like 'Xerox%'
group by Product_Name
having round(sum(sales),2)  > 10000
order by Revenue desc

-- Which product was purchased the most?
select count(product_name) as NumPurchases, Product_Name, Category
from PortfolioProject..Superstore
group by Product_Name, Category
having count(product_name) > 8
order by NumPurchases desc


-- Amount of different products purchased in each state
with cte as (
	select distinct State, count(Product_Name) over (partition by state) NumProductByState, 
	sum(sales) over (partition by state)as Revenue 
	from PortfolioProject..Superstore
	--where state = 'California'
	group by State, Product_Name, sales
	--order by Revenue desc
	)
select state, NumProductByState, round(revenue,2) Revenue 
from cte
where NumProductByState > 150
order by Revenue desc

-- Which states had the highest revenue by product category?
select State, Category, sum(sales) as Revenue, count(distinct Product_Name) as NumProductsPurchased
from PortfolioProject..Superstore
--where state = 'California'
group by State, Category
having count(distinct Product_Name) > 100
order by Revenue desc

-- Average revenue of a product category and sub-category
select  Category, sub_category, avg(sales) as AvgRevenue
from PortfolioProject..Superstore
group by  Category, Sub_Category
order by 3 desc

-- What are the average sales of each product category and sub-category (sorted by "Good" and "Bad")?

select Category, Sub_Category,  avg(Sales) AvgSales, (select avg(sales) from superstore) AllAvgSales,
case
	when avg(sales) > (select avg(sales) from superstore) then 'Good'
	else 'Bad'
	end as 'Averages'
from PortfolioProject..Superstore
group by  Category,  Sub_Category
order by 3 desc

	-- Average sales of each product sorted by "Good" and "Bad"
select Category, Sub_Category, Product_name,  Sales, avg(sales) over (partition by sub_category) AvgSales,
case
	when sales > avg(sales) over (partition by sub_category) then 'Good'
	else 'Bad'
	end as 'Averages'
from PortfolioProject..Superstore
--where Product_Name = 'Microsoft Natural Keyboard Elite'
group by  Category, sales, Sub_Category, Product_Name


---Sales Analysis---


-- What are the average sales in every month and year?
	-- Month
select OrderDateMonth, round(avg(sales),2) AvgRevenue
from PortfolioProject..Superstore
group by OrderDateMonth 
order by 2 desc
	-- Year
 select  OrderDateYear, round(avg(sales),2) AvgRevenue
from PortfolioProject..Superstore
group by  OrderDateYear
order by 2 desc
 
-- What is the total sales revenue by year/month?
	-- Month
select OrderDateMonth, round(sum(sales),2) TotalRevenue
from PortfolioProject..Superstore
group by OrderDateMonth
order by 2 desc
	-- Year
select OrderDateYear, round(sum(sales),2) TotalRevenue
from PortfolioProject..Superstore
group by OrderDateYear
order by 2 desc

-- Which day of the week had the highest sales?
select OrderDateDay, round(max(sales),2) MostSales
from PortfolioProject..Superstore
group by OrderDateDay
order by 2 desc

-- What are the average sales on every day of the week?
select OrderDateDay, round(avg(sales),2) AvgSales
from PortfolioProject..Superstore
group by OrderDateDay
order by 2 desc

--Creating views for later visualizations

create view  AvgProductSales  as
select Category, Sub_Category,  avg(Sales) AvgSales, (select avg(sales) from superstore) AllAvgSales,
case
	when avg(sales) > (select avg(sales) from superstore) then 'Good'
	else 'Bad'
	end as 'Averages'
from PortfolioProject..Superstore
group by  Category,  Sub_Category

create view ProductsByState as
with cte as (
	select distinct State, count(Product_Name) over (partition by state) NumProductByState, 
	sum(sales) over (partition by state)as Revenue 
	from PortfolioProject..Superstore
	--where state = 'California'
	group by State, Product_Name, sales
	--order by Revenue desc
	)
select state, NumProductByState, round(revenue,2) Revenue 
from cte
where NumProductByState > 150
--order by Revenue desc

create view ProductRevenue as
select count(product_name) as NumPurchases, Product_Name, round(sum(sales),2) as Revenue
from PortfolioProject..Superstore
--where Product_Name like 'Xerox%'
group by Product_Name
having round(sum(sales),2)  > 10000
--order by Revenue desc


