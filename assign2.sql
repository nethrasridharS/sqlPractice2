use sql_assignment_2;
select * from customers;
select * from products;
select * from orders;
select * from order_items;
select * from payments;

--Question-01;
select * from products
order by price desc;

--Question 2;
select product_name , category, brand , price from products
where price > 10000
order by price desc;

--Question 03;
select distinct product_name from products;

--question 04;
select * from orders
order by order_date desc
limit 10;

--Question 05;
select product_name , category, price, stock_quantity from products
where stock_quantity < 20;

--INTERMEDIATE SQL;

--Question 06;
select category , count(product_name) as product_count,
avg(price) as price_avg ,
max(price) as highest_amount,
min(price) as lowest_amount from products
group by category
order by price_avg desc;

--Question 07;
select  c.customer_id , c.customer_name , count(o.order_id) as total_orders
from customers as c
join orders as o 
on c.customer_id = o.customer_id
group by o.customer_id
having count(*) > 1;

--Question 08;
select p.product_name , count(o.quantity) as total_quantity,
 sum(o.quantity * o.unit_price * (1-discount/100))as total_revenue
 from products as p
 join order_items as o
 on p.product_id = o.product_id
 group by p.product_name
 order by total_revenue desc;
 
 --Question 09;
 select order_status, count(*) as total_count, 
 count(*) * 100.0 / (select count(*) from orders) as percentage
 from orders 
 group by order_Status;
 
 --Question 10;
 select o.shipping_city, count(o.order_id) as count_of_orders,
 sum(oi.unit_price) as revenue, avg(o.order_id) as avg_of_orders
 from orders as o
 join order_items as oi
on o.order_id = oi.order_id
group by o.shipping_city;

--Question 11;
select c.customer_name , count(o.order_id) as total_orders, 
sum(oi.quantity * oi.unit_price * (1-oi.discount/100)) as total_revenue
from customers as c
join orders as o 
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
group by c.customer_name
order by total_revenue desc
limit 5;
 
 --Question 12;
 select c.customer_id , c.customer_name
 from customers as c
left join orders as o
on c.customer_id = o.customer_id
where o.order_id is  null;

--question 13;
with productRevenue as(
select p.product_name,
 sum(o.quantity * o.unit_price) as revenue
from order_items as o
join products as p
on p.product_id = o.product_id
group by p.product_name
)
select product_name, revenue,
avg(revenue)
over() as averaged_revenue from productRevenue
where revenue > (
		select avg(revenue) from productRevenue
);

--Question 14;
select year(o.order_date) as sales_year,
date_format(o.order_date,'%m') as sales_month,
count(distinct o.order_id) as order_count,
sum(oi.quantity) as total_quantity,
sum(oi.quantity * oi.unit_price) as total_revenue
from orders as o
join order_items as oi
on o.order_id = oi.order_id
group by year(o.order_date) , date_format(o.order_date,'%m')
order by sales_year , sales_month;

--Question 15;
with product_revenue as(
select p.product_name , p.category,
 sum(o.quantity * o.unit_price) as revenue
from order_items as o
join products as p
where o.product_id = p.product_id
group by p.product_name , p.category
)select category, product_name, revenue,
rank()
over(
partition by category
order by revenue desc
) as ranked_products
 from product_revenue;
 
 --Question 16;
select
c.customer_id,
c.customer_name,
count(distinct o.order_id) as order_count,
sum(oi.quantity * oi.unit_price) as revenue,
sum(oi.quantity * oi.unit_price) / count(distinct o.order_id) as avg_order_value,
case
when count(distinct o.order_id) = 1 then 'one-time'
when count(distinct o.order_id) = 2 then 'returning'
else 'loyal'
end as customer_type
from customers c
join orders o 
on c.customer_id = o.customer_id
join order_items oi 
on o.order_id = oi.order_id
group by c.customer_id, c.customer_name
having count(distinct o.order_id) >= 3
order by order_count desc;

--Question 17;
with monthly as (
select date_format(o.order_date, '%y-%m') as month,
sum(oi.quantity * oi.unit_price) as revenue from
orders o
join order_items oi 
on o.order_id = oi.order_id
group by date_format(o.order_date, '%y-%m')
)
select
month,
revenue,
lag(revenue) over (order by month) as prev_month_revenue,
case
when lag(revenue) over (order by month) is null then null
when lag(revenue) over (order by month) = 0 then null
else round((revenue - lag(revenue) over (order by month)) * 100.0 / lag(revenue) over (order by month), 2)
end as mon_growth_pct
from monthly
order by month;

--Question 18;
with customer_sales as (
select c.customer_id, c.customer_name,
count(distinct o.order_id) as order_count,
sum(oi.quantity) as items_purchased,
sum(oi.quantity * oi.unit_price) as revenue,
sum(oi.quantity * oi.unit_price) / count(distinct o.order_id) as avg_order_value
from customers c
join orders o 
on c.customer_id = o.customer_id
join order_items oi 
on o.order_id = oi.order_id
group by c.customer_id, c.customer_name
)
select * from customer_sales
where revenue > 50000
order by revenue desc;

--Question19;
create table customer_sales_summary as
select c.customer_id, c.customer_name, c.city,
count(distinct o.order_id) as total_orders,
sum(oi.quantity) as total_quantity,
sum(oi.quantity * oi.unit_price) as revenue,
sum(oi.quantity * oi.unit_price) / count(distinct o.order_id) as avg_order_value,
min(o.order_date) as first_order_date,
max(o.order_date) as last_order_date
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
group by c.customer_id, c.customer_name, c.city;

select * from customer_sales_summary
order by revenue desc limit 5;

select city, sum(revenue) as city_revenue, count(*) as customers
from customer_sales_summary
group by city
order by city_revenue desc;

select * from customer_sales_summary
where revenue > 30000
order by revenue desc;

--Question 20;
select count(distinct o.order_id) as total_orders,
count(distinct o.customer_id) as total_customers,
sum(oi.quantity) as quantity_sold,
sum(oi.quantity * oi.unit_price) as total_revenue,
sum(oi.quantity * oi.unit_price) / count(distinct o.order_id) as avg_order_value
from orders o
join order_items oi
 on o.order_id = oi.order_id;

select order_status, count(*) as orders
from orders
group by order_status;

select count(*) as total,
    sum(case when order_status = 'cancelled' then 1 else 0 end) * 100.0 / count(*) as cancellation_pct,
    sum(case when order_status = 'returned' then 1 else 0 end) * 100.0 / count(*) as return_pct
from orders;

select * from customer_sales_summary
order by revenue desc limit 5;