---Customer Exploratory Data Analysis---
--Dataset: Customer Shopping Trends (2023)

select top 1000 *
from PortfolioProject..CustomerData d 
join PortfolioProject..CustomerPayments p
	on d.Customer_ID = p.Customer_ID

-- Adding  columns to classify customers' age as "Young", "Middle Aged", and "Old"
select Age,
	case 
		when Age <= 34 then 'Young'
		when Age > 34 and Age <= 50 then 'Middle Aged'
		else 'Old'
		end as AgeBracket
from PortfolioProject..CustomerData

alter table CustomerData
add AgeBracket varchar(15) 

update CustomerData
set AgeBracket = case 
		when Age <= 34 then 'Young'
		when Age > 34 and Age <= 50 then 'Middle Aged'
		else 'Old'
		end 

--General Questions--

--What is the age range of the customers in the dataset?
select count(distinct age) AgeRange, min(age) MinAge, max(age) MaxAge
from PortfolioProject..CustomerData 

--How many dstinct locations (states) does the dataset cover?
select count(distinct location) NumStates
from PortfolioProject..CustomerData

--How many distinct items and item categories are there?
select count(distinct Category) NumCategories, count(distinct Item_Purchased) NumItems
from PortfolioProject..CustomerData

 ---Customer Exploratory Data Analysis---

-- Which customers purchased the most?
select d.Customer_ID, max(p.Previous_Purchases) MostPurchases
from PortfolioProject..CustomerData d
join PortfolioProject..CustomerPayments p 
	on d.Customer_ID = p.Customer_ID
group by d.Customer_ID
having max(p.Previous_Purchases) > 35
order by 2 desc

-- What are the most purchased categories by AgeBracket?
select Category, AgeBracket, count(Category) NumCategPurchased
from PortfolioProject..CustomerData
group by Category, AgeBracket
order by 3 desc

-- Which age bracket purchased the most?
select  AgeBracket, count(Item_Purchased) NumItemsPurchased
from PortfolioProject..CustomerData
group by  AgeBracket
order by 2 desc

-- Percentage of customers that used a promo code
select p.Promo_Code_Used, count(p.Promo_Code_Used) NumPromoCode, (select count(customer_ID) from PortfolioProject..CustomerData) TotalCustomers
, cast(round(count(p.Promo_Code_Used)*1.0/(select count(customer_ID) from PortfolioProject..CustomerData)*100,1)as Decimal(8,1)) PromoCodePercentage
from PortfolioProject..CustomerData d
join PortfolioProject..CustomerPayments p
	on d.Customer_ID = p.Customer_ID
group by p.Promo_Code_Used

-- Percentage of customers that are subscribed
select Subscription_Status, count(Subscription_Status) NumSubs, (select count(customer_ID) from PortfolioProject..CustomerData) TotalCustomers
, cast(round(count(Subscription_Status)*1.0/(select count(customer_ID) from PortfolioProject..CustomerData)*100,1)as Decimal(8,1)) SubStatusPercentage
from PortfolioProject..CustomerData 
group by Subscription_Status

-- Average purchase amount by customer age bracket and gender
select AgeBracket, Gender, avg(Purchase_Amount_USD) AvgPurchaseAmnt
from PortfolioProject..CustomerData
group by AgeBracket, Gender
order by 3 desc

-- What are the most purchased items?
select Category, Item_Purchased, count(Item_Purchased) NumItemsPurchased
from PortfolioProject..CustomerData
group by Category, Item_Purchased
order by 3 desc

-- Most popular items by customer gender and age
select AgeBracket, Gender, Item_Purchased, count(Item_Purchased) NumItemsPurchased
from PortfolioProject..CustomerData
where Gender = 'Male' and AgeBracket = 'Young'
group by AgeBracket, Gender, Item_Purchased
--order by 4 desc
union
select AgeBracket, Gender, Item_Purchased, count(Item_Purchased) NumItemsPurchased
from PortfolioProject..CustomerData
where Gender = 'Male' and AgeBracket = 'Old'
group by AgeBracket, Gender, Item_Purchased
order by 4 desc

-- Most popular payment methods by Age and Gender
select d.Gender, d.AgeBracket, p.Payment_Method, count(p.Payment_Method) NumPaymentMethod
from PortfolioProject..CustomerData d
join PortfolioProject..CustomerPayments p
	on d.Customer_ID = p.Customer_ID
where d.AgeBracket = ('Young') and d.Gender = 'Male'
group by d.Gender, d.AgeBracket, p.Payment_Method
--order by 4 desc
union
select d.Gender, d.AgeBracket, p.Payment_Method, count(p.Payment_Method) NumPaymentMethod
from PortfolioProject..CustomerData d
join PortfolioProject..CustomerPayments p
	on d.Customer_ID = p.Customer_ID
where d.AgeBracket = 'Old' and d.Gender = 'Male'
group by d.Gender, d.AgeBracket, p.Payment_Method
order by 4 desc

-- What are the most purchased categories by location?
select category, location, count(Item_Purchased)  NumItemsPurchased
from PortfolioProject..CustomerData
where Category = 'Clothing'
group by  location, Category
order by 3 desc

-- Which season do customers purchase the most?
select season, count(season) NumPurchases, sum(purchase_amount_USD) Revenue
from PortfolioProject..CustomerData
group by season
order by 2 desc

-- Most popular frequency of purchase among different age brackets
select d.AgeBracket, p.Frequency_of_Purchases, count(p.Frequency_of_Purchases) FreqPurchase
from PortfolioProject..CustomerData d
join PortfolioProject..CustomerPayments p 
	on d.Customer_ID = p.Customer_ID
where d.AgeBracket in ('Young', 'Old')
group by d.AgeBracket, p.Frequency_of_Purchases
order by 3 desc

-- Which age range and gender has the highest frequency of purchases?
select d.AgeBracket, d.gender, p.Frequency_of_Purchases, count(p.Frequency_of_Purchases) FreqPurchase
from PortfolioProject..CustomerData d
join PortfolioProject..CustomerPayments p 
	on d.Customer_ID = p.Customer_ID
where p.Frequency_of_Purchases in ('Weekly', 'Bi-Weekly')
group by d.AgeBracket, p.Frequency_of_Purchases, d.gender
order by 4 desc

-- Average rating across all product categories 
select Category, Item_Purchased, round(avg(Review_Rating),3) AvgRating
from PortfolioProject..CustomerData
group by Category, Item_Purchased
order by 3 desc

-- Average rating across all items sorted by "Good", "Average", and "Bad"
with cte as (
select Category, Item_Purchased, round((Review_Rating),3) AvgRating,
	case 
		when (Review_Rating) <3 then 'Bad'
		when (Review_Rating) >=3 and (Review_Rating) <4 then 'Average'
		else 'Good'
		end as RatingCategory
from PortfolioProject..CustomerData
group by Category, Item_Purchased,Review_Rating
--order by 3 desc
)
select avgrating, count(avgRating) NumRatings, RatingCategory, count(RatingCategory) over (partition by ratingCategory) NumRatingCategory
from cte
group by AvgRating, RatingCategory
order by AvgRating desc

-- What are the highest rated items?
select Category, Item_Purchased, (review_rating), count(review_rating) NumItemRatings, sum(count(Review_Rating)) over (partition by review_rating) TotalNumRatings
from PortfolioProject..CustomerData
where Review_Rating > 4.0
group by Item_Purchased, Category, Review_Rating
order by 3 desc

-- Number of items by rating 
select round(review_rating,3) Rating, count(review_rating) NumItems
from PortfolioProject..CustomerData
--where Review_Rating =5
group by Review_Rating
order by 1 desc

-- Average number of previous purchases by age bracket and gender
select d.AgeBracket, d.Gender, avg(p.previous_purchases) AvgPrevPurchases
from PortfolioProject..CustomerData d 
join PortfolioProject..CustomerPayments p
	on d.Customer_ID = p.Customer_ID
group by d.AgeBracket, d.Gender
order by 3 desc

-- Most popular shipping type by Age and Gender
select AgeBracket, Gender, Shipping_Type, count(shipping_type) NumShippingType
from PortfolioProject..CustomerData
where AgeBracket = 'Young' and Gender = 'Male'
--where Shipping_Type in( 'Standard', 'Express')
group by AgeBracket, Gender, Shipping_Type
--order by 4 desc
union 
select AgeBracket, Gender, Shipping_Type, count(shipping_type) NumShippingType
from PortfolioProject..CustomerData
where AgeBracket = 'Old' and Gender = 'Male'
--where Shipping_Type in( 'Standard', 'Express')
group by AgeBracket, Gender, Shipping_Type
order by 4 desc


-- Creating views for later visualizations
create view PromoCodePercentage as
select p.Promo_Code_Used, count(p.Promo_Code_Used) NumPromoCode, (select count(customer_ID) from PortfolioProject..CustomerData) TotalCustomers
, cast(round(count(p.Promo_Code_Used)*1.0/(select count(customer_ID) from PortfolioProject..CustomerData)*100,1)as Decimal(8,1)) PromoCodePercentage
from PortfolioProject..CustomerData d
join PortfolioProject..CustomerPayments p
	on d.Customer_ID = p.Customer_ID
group by p.Promo_Code_Used

create view PaymentMethods as
select d.Gender, d.AgeBracket, p.Payment_Method, count(p.Payment_Method) NumPaymentMethod
from PortfolioProject..CustomerData d
join PortfolioProject..CustomerPayments p
	on d.Customer_ID = p.Customer_ID
where d.AgeBracket = 'Young' and d.Gender = 'Male'
group by d.Gender, d.AgeBracket, p.Payment_Method
--order by 4 desc

create view AvgPreviousPurchases as
select d.AgeBracket, d.Gender, avg(p.previous_purchases) AvgPrevPurchases
from PortfolioProject..CustomerData d 
join PortfolioProject..CustomerPayments p
	on d.Customer_ID = p.Customer_ID
group by d.AgeBracket, d.Gender
--order by 3 desc

create view NumPaymentMethods as
select p.Payment_Method, count(p.Payment_Method) NumPaymentMethod
from PortfolioProject..CustomerData d
join PortfolioProject..CustomerPayments p
	on d.Customer_ID = p.Customer_ID
group by  p.Payment_Method
order by 2 desc
