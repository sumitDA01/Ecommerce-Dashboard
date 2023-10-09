create database ecommerce;

use ecommerce;


-- counting rows in customer
select count(*)  from customers;

-- number of cusotomers with A-Z 
select left(firstname,1),count(*) from customers 
group by left(firstname,1)
order by left(firstname,1);

-- Age category for customers
select customerid,firstname,lastname, case 
when year(date_of_birth)<1995 then "Old" 
when year(date_of_birth)>=1995 then "Young" end as AGE_Category
from customers 
order by customerid;


-- Counting the number of different states the customers reside in.
select COUNT( DISTINCT STATE) as total_state from  customers;


-- Printing all the unique City names the customers belong to, order output in alphabetical order of City name.
select distinct city from customers
order by city;

 -- find total revenue for each customer whose Country is 'India'.
select b.customerid ,sum(total_order_amount) as total 
from customers as a 
join orders as b 
on a.customerid = b.customerid 
where country like 'India' 
group by b.customerid 
order by total DESC;

-- highest order day
select DAYNAME(orderdate) as date, avg(total_order_amount) as avgg, count(orderid) 
from orders 
group by date 
order by avgg DESC;


-- customers total count
select monthname(dateentered),count(*) as Total_count from customers 
group by 1 
order by Total_count DESC 
limit 5;


-- Total Shipper Sales
select B.SHIPPERID,SUM(total_order_amount) 
from ORDERS AS A 
join SHIPPERS AS B 
on A.SHIPPERID = B.SHIPPERID 
group by B.SHIPPERID 
order by  B.SHIPPERID;


-- Orders into three category  
SELECT CASE 
WHEN Total_Order_amount <= 10000 THEN 'Regular Order' 
WHEN Total_Order_amount <= 60000 THEN 'Not So Expensive Order' 
WHEN Total_Order_amount > 60000 THEN 'Expensive Order' END as Order_Types, COUNT(*) as total 
FROM Orders 
GROUP BY Order_Types
ORDER BY Total DESC;

-- the highest order amount and it's corresponding order date for each customer
with cte as (
select customerid,orderdate,total_order_amount,
dense_rank() over (partition by customerid order by total_order_amount desc) as rnk from orders )
select customerid,orderdate,total_order_amount from cte where rnk = 1;


-- Identify top 3 Countries whose customers placed the most orders.
select COUNTRY, COUNT(*) FROM CUSTOMERS A JOIN ORDERS b ON A.CUSTOMERID = B.CUSTOMERID 
group by  COUNTRY
order by COUNT(*) DESC 
limit 3;


-- All payment type with  print sum of total amount ,avg of total amount,min and max,count
select b.paymenttype,b.allowed,sum(a.total_order_amount),avg(a.total_order_amount), max(a.total_order_amount),min(a.total_order_amount),
count(total_order_amount) 
from orders a 
right join payments b 
on a.paymentid = b.paymentid 
group by b.paymenttype,b.allowed 
order by b.paymenttype;


-- total amount value in 2020 and 2021
select paymenttype, allowed, 
sum(case when year(orderdate) = 2020 then total_order_amount else null end) as total_transaction_value_2020 , 
sum(case when year(orderdate) = 2021 then total_order_amount else null end) as total_transaction_value_2021 
from payments a 
left join orders b 
on a.paymentid = b.paymentid 
group by paymenttype,allowed 
order by paymenttype;


-- Identify which was the highest transaction value for each payment method
select a.paymentid, a.paymenttype, max(total_order_amount) 
from payments a 
left join orders b 
on a.paymentid = b.paymentid 
group by a.paymentid, a.paymenttype 
order by paymentid;


-- Customers and their total spending greater than 350000
select a.customerid,firstname,lastname,country,sum(total_order_amount) as total from customers a 
join orders b 
on a.customerid = b.customerid 
group by customerid,firstname,lastname,country 
having total >350000 
order by total desc, a.customerid;

-- Average Delivery Time Dashboard
select city,state,country , 
round(avg(timestampdiff(day,orderdate,deliverydate)),2) 
from customers a 
join orders b 
on a.customerid = b.customerid 
group by city,state,country 
order by 4,1;


-- Top 10 products ordered more in total order amount
select product,sum(total_order_amount) as total_order_amount from orders as a join
orderdetails as od 
on a.orderid = od.orderid
join products as p 
on od.productid = p.productid
group by product
order by total_order_amount DESC, product
limit 10;


-- The top 2 products for each category with the highest market price. 
with cte as 
(select productid,product,market_price,category_id, dense_rank() over (partition by category_id order by market_price DESC) as rnk 
from products 
order by category_id,rnk) 
select productid,product,category_id,market_price, rnk from cte 
where rnk = 1 or rnk = 2;


-- city's most orders
with cte as( 
select country,city, count(orderid) as cnt from customers natural join orders group by country,city order by country,city )
, cte1 as( 
select *,dense_rank() over(partition by country order by cnt DESC) as rnk from cte ) 
select country,city,cnt from cte1 
where rnk =1 
order by country,city;

--  top 5 categories which had the highest quantity of products ordered.
select categoryid,categoryname,sum(quantity) as qty 
from category as c 
join products as p 
on p.category_id = c.categoryid 
join orderdetails as o on o.productid = p.productid 
group by categoryid ,categoryname
order by qty DESC 
limit 5;

-- payment insights
with cte as ( 
select p.paymentid,paymenttype,count(o.orderid) as cnt,count(distinct o.customerid) cust,ifnull(sum(total_order_amount),'No Payment') as total 
from customers as c 
join orders as o 
on c.customerid = o.customerid 
right join payments p 
on p.paymentid = o.paymentid 
group by p.paymentid,paymenttype) 
select paymentid,paymenttype,
case when cnt = 0 then 'No orders' else cnt end as orders, 
case when cust = 0 then 'No customers' else cust end as customers,total 
from cte 
order by paymentid;









