                ---------------* global_sales_schemas*--------------

---customer table 
drop table if exists customers;
create table customers(
                        customer_id int primary key,
						customer_name varchar(50),
						city varchar(50),
						state varchar(50),
						country varchar(50),
						region varchar(50)

);

---orders table 
drop table if exists orders;
create table orders(
					Order_ID int primary key,
					Customer_ID	int references customers(customer_id),
					Order_Date date,
					Order_Priority varchar(20)
);

---order_items table 
drop table if exists order_items;
create table order_items(
						order_item_id int primary key,
						Order_ID int references orders(order_id),
						Product_ID int references products(product_id),
						Quantity int,
						Sales numeric(12,2),	
						Discount NUMERIC(12,2),	
						Profit numeric(12,2)
);

---products table 
drop table if exists products;
create table products(
					Product_ID int primary key,
					product_name varchar(50),
					Category varchar(50),
					Segment varchar(50)				
);

---shipping table 
drop table if exists shipping;
create table shipping(
						Shipping_id int primary key,
						order_id int references orders(order_id),
						Ship_Date date,
						Ship_Mode varchar(30),
						Shipping_Cost NUMERIC(12,2)	

);


select * from customers;
select * from orders;
select * from order_items;
select * from products;
select * from shipping;

select distinct(order_priority) from orders

select count(*) as total
from customers;


                             -----* LEVEL 1: BASIC SQL *-----

---1.List all customers who live in “Seattle”.

select *
from customers
where City = 'Seattle' and	State = 'Washington' and Country = 'United States' and Region = 'Western US';

---2.Show all customers from Australia

select *
from customers
where Country = 'Australia';

---Count total number of customers per Country

select count(Country) as total_customer
from customers;

---List all orders with High priority

select *
from orders
where order_priority = 'High';

---Find total number of orders

select count(order_id) as total_orders
from orders;

---Display unique ship modes

select distinct(ship_mode) as unique
from shipping;





                            -----* LEVEL 2: FILTERING & SORTING *-----

---7.Find customers from India OR Germany

select *
from customers
where Country in ('India', 'Germany');

---8.Orders placed between Jan–Mar 2014

select *
from orders
where Order_Date >= '2014-01-01'
	and Order_Date < '2014-03-01';

---9.Top 5 highest shipping costs

select * from shipping
order by shipping_cost desc
limit 5

---10.Customers whose name starts with A

select *
from customers
where customer_name like 'A%';

---11.Orders sorted by Order Date (latest first)

select * 
from orders
order by Order_Date desc;



							-----* LEVEL 3: AGGREGATE FUNCTIONS *-----

---12.Total sales from order_items

select sum(sales) as total_sales
from order_items;

---13.Average profit per order

select avg(profit) as avg_profit
from order_items;

---14.Maximum and minimum shipping cost

select max(Shipping_Cost) as max_scost,
	   min(shipping_cost) as min_scost
from shipping;

---15.Total quantity sold

select sum(Quantity) as total_quantity
from order_items;

---16.Total profit by Category

select p.category, 
		sum(oi.profit) as total_profit
from order_items oi
join products p on oi.product_id = p.product_id
group by p.category;

						 	  -----* LEVEL 4: GROUP BY + HAVING *-----

---17.Total orders per customer

select o.customer_id,
		c.customer_name,
		count(o.order_id) as total_orders
from orders o
join customers c on c.customer_id = o.customer_id
group by 1,2
having count(order_id) > 5
order by total_orders desc;

---18.Customers with more than 3 orders

select 
    c.customer_name,
    count(o.order_id) as total_orders
from customers c
join orders o 
    on o.customer_id = c.customer_id
group by c.customer_name
having count(o.order_id) > 3
order by total_orders desc;

---19.Average shipping cost per ship mode

select ship_mode,
		avg(shipping_cost) as avg_scost		
from shipping
group by ship_mode
having avg(shipping_cost) > 40
order by avg_scost desc;

---20.Profit per region

select c.region,
		sum(oi.profit) total_profit
from customers c
join orders o on o.customer_id = c.customer_id
join order_items oi on oi.order_id = o.order_id
group by 1
having sum(oi.profit) > 30000
order by total_profit desc;

---21.Categories with total sales = 1010535.76

select p.category,
		sum(oi.sales) as total_sales
from order_items oi
join products p on p.product_id = oi.product_id
group by 1
having sum(oi.sales) = 1010535.76;

---22.Customers who bought more than 3 items

select c.customer_name,
		oi.order_item_id,
		sum(oi.Quantity) as total_quantity
from customers c
join orders o on o.customer_id = c.customer_id
join order_items oi on oi.order_id = o.order_id
group by 1,2
having sum(oi.Quantity) > 3
order by total_quantity;


						 		 -----* LEVEL 5: JOINS ****-----

---23.Customer name with their order count

select c.customer_name,
		count(o.order_id) as order_count
from customers c
join orders o on o.customer_id = c.customer_id
group by 1
order by order_count desc;

---24.Orders with customer city and country

select o.order_id,
	   o.order_date,
		c.city, 
		c.country
from customers c
join orders o on c.customer_id = o.customer_id;

---25.Order details with shipping mode

select o.order_id,
	   o.order_date,
	   s.ship_mode
from orders o
join shipping s on o.order_id = s.order_id;

---26.Product category with total profit

select p.category,
		sum(oi.profit) as total_profit
from order_items oi
join products p on oi.product_id = p.product_id
group by 1
order by total_profit desc;
		
---27.Customers who never placed an order (LEFT JOIN)

select c.customer_id,
		c.customer_name
from customers c
join orders o on o.customer_id = c.customer_id	
where o.order_id is null;

						 		-----* LEVEL 6: CASE WHEN *-----

---Classify profit as Loss / Low / High

select order_id, profit,
case 
	when profit < 0 then 'loss'
	when profit between 0 and 500 then 'low'
	else 'high'
end as profit_type
from order_items
limit 10;

---Shipping cost category (Cheap / Expensive)

select shipping_id, shipping_cost,
case 
   when shipping_cost is null then 'unknown'
   when shipping_cost < 100 then 'cheap'
   else 'expensive'
end as shipping_ccategory
from shipping;
 
---Order priority label (Critical → Urgent)

select order_id, order_priority,
case 
   when order_priority = 'critical' then 'critical'
   when order_priority = 'high' then 'urgent'
   when order_priority = 'medium' then 'normal'
   else 'low'
end as priority_label
from orders; 

---Discount flag (Yes / No)

select order_item_id, discount,
case
	when discount is null or discount = 0 then 'no'
	else 'yes'
end as discount_flag
from order_items;

---Customer type based on order count

with order_count as(
select 
	c.customer_id,
    c.customer_name,
    count(o.order_id) as total_orders
from customers c
left join orders o 
    on o.customer_id = c.customer_id
group by 1,2
)
select *,
case 
	when total_orders > 80 then 'excellent'
	when total_orders between 50 and 80 then 'good'
	else 'average'
end as customer_type
from order_count;
								-----* LEVEL 7: DATE FUNCTIONS *-----

---Extract year from order date

select *,
		extract(year from order_date) as extract_date
from orders;

---Monthly order count

select 
 	 extract(year from order_date) as year,
   	 extract(month from order_date) as month,
		count(order_id) order_count
from orders
group by 1,2
order by 1,2;

---Shipping delay (Ship Date − Order Date)

with joining_data as(
	select
	o.order_id,
	o.order_date,
			s.shipping_id,
			s.ship_date
	from orders o
	join shipping s on s.order_id = o.order_id
)
select *,
		ship_date - order_date as ship_delay
from joining_data;

---Orders per weekday

select 
	to_char(order_date, 'month') as weekday,
	count(order_id) as order_count
from orders
group by weekday 
order by order_count;

---Year-wise total sales

with join_data as(
select o.order_date,
		oi.sales
from orders o
join order_items oi on oi.order_id = o.order_id
)
select 
		TO_CHAR(order_date, 'YYYY-MM') AS year_month,
		sum(sales) as total_sales
from join_data
group by year_month 
order by total_sales;

								-----* LEVEL 8: STRING FUNCTIONS 
								

---Convert customer names to UPPER

select 
		customer_name,
		upper(customer_name) as up_name
from customers;

---Extract first name from customer_name

select 
	customer_name,
	split_part(customer_name, ' ', 1) as first_name
from customers;

---Replace space with underscore in names

select 
	customer_name,
	replace(customer_name, ' ', '_') as names
from customers;

---Length of product names

select product_name,
		length(product_name) as length_name
from products;
    
---Customers whose name contains “son”

select *
from customers
where customer_name ilike '%son%' and country = 'India';

								-----* LEVEL 9: SUBQUERIES *-----

---Customers with above-average profit

select c.customer_id,
	   c.customer_name,
	   sum(oi.profit) as total_profit
from customers c
join orders o on o.customer_id = c.customer_id
join order_items oi on oi.order_id = o.order_id
group by 1,2
having sum(oi.profit) > (
	select avg(total_profit) 
	from(
		select sum(profit) as total_profit
		from order_items
		--group by customer_id
		) t
		)
		order by total_profit desc;

---Orders with shipping cost higher than average

with avg_shipping as(
	select avg(shipping_cost) as avg_scost
	from shipping
)
select
	o.order_id,
	o.order_date,
	s.shipping_cost
from orders o
join shipping s on o.order_id = s.order_id
where shipping_cost > (select avg_scost from avg_shipping);

--or

WITH avg_shipping AS (
    SELECT AVG(shipping_cost) AS avg_ship_cost
    FROM shipping
)
SELECT 
    s.order_id,
    s.shipping_cost
FROM shipping s
JOIN avg_shipping a
    ON s.shipping_cost > a.avg_ship_cost
ORDER BY s.shipping_cost DESC;

---Products with highest sales

with product_sales  as(
	select product_id,
			sum(sales) as total_sales
	from order_items
	group by 1
)
select p.product_id,
	   p.product_name,
	   ps.total_sales
from product_sales ps
join products p on p.product_id = ps.product_id
where ps.total_sales = (
		select max(total_sales) 
		from product_sales
)

---Customers from the region with max orders

with region_orders as(
	select c.region,
		count(o.order_id) as total_orders
	from customers c
	join orders o on o.customer_id = c.customer_id
	group by c.region
),
max_region as(
	select region
	from region_orders
	where total_orders =(
				select max(total_orders)
				from region_orders
	)
)
select  c.customer_id,
    	c.customer_name,
   	    c.region
from customers c
join max_region mr on c.region = mr.region

---Second highest shipping cost

select shipping_cost
from(
	select shipping_cost,
			   dense_rank() over(order by shipping_cost desc) as rnk
	from shipping
) t
where rnk = 2;

								-----*LEVEL 10: WINDOW FUNCTIONS *-----

---Rank customers by total sales

select customer_id,
       total_sales,
	   dense_rank() over(order by total_sales desc) as rank
from(
	select c.customer_id,
	sum(oi.sales) as total_sales
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
group by c.customer_id
) as t

---Running total of sales

select
	o.order_date,
	oi.sales,
	sum(oi.sales) over(order by order_date 
	rows between unbounded preceding and current row) as running_total
from orders o
join order_items oi on o.order_id = oi.order_id
order by order_date

---Dense rank of products by profit

with ranking as(
select p.product_name,
       sum(oi.profit) as total_profit
from order_items oi
join products p on oi.product_id = p.product_id
group by product_name
)
select product_name,
       total_profit,
	   dense_rank() over(order by total_profit desc) as rnk
from ranking

---Order count per customer using OVER()

with counting as(
select o.customer_id,
		c.customer_name,
		o.order_id 
from orders o
join customers c on c.customer_id = o.customer_id
)
select *,
		count(order_id) over(partition by customer_id) as order_count
from counting;

---Top 3 customers per region

with joining_table as(
	select c.customer_id,
			c.customer_name,
			c.region,
			sum(oi.sales) as total_sales
	from customers c
	join orders o on c.customer_id = o.customer_id
	join order_items oi on o.order_id = oi.order_id
	group by 1,2,3
	),
ranking as(
	select *,
 		dense_rank() over(partition by region order by total_sales) as rnk
	from joining_table
)
select customer_id,
	   customer_name,
	   region,
	   total_sales,
	   rnk
from ranking
where rnk <= 3
order by region, rnk;
	

								-----* CTE (WITH) *-----

---CTE to calculate customer lifetime value

with customer_clv as(
	select c.customer_id,
		   c.customer_name,
		   sum(oi.profit) as lifetime_profit
	from customers c
	join orders o on c.customer_id = o.customer_id
	join order_items oi on o.order_id = oi.order_id
	group by 1,2
		
)
select *
from customer_clv
order by lifetime_profit desc;

--CTE for monthly sales trend

with monthly_sale as(
	select date_trunc('month', o.order_date) as sales_month,
		   sum(oi.profit) as total_profit
	from orders o
	join order_items oi on o.order_id = oi.order_id
	group by date_trunc('month', o.order_date)

)
select sales_month,
	   total_profit
from monthly_sale
order by sales_month desc;

---Profit margin per product

with product_profit as(
	select p.product_id,
	  	   p.product_name,
	  	   sum(oi.profit) as total_pofit,
	   	   sum(oi.sales) as total_sales
	 from order_items oi
	 join products p on oi.product_id = p.product_id
	 group by 1,2
)
select product_id,
	   product_name,
	   total_pofit,
	   total_sales,
	   round((total_pofit / nullif(total_sales,0)) * 100, 2) as profit_margin
from product_profit
order by profit_margin desc

---Repeat customers using CTE

with repeat_customer as(
	select c.customer_name,
		   c.customer_id,
		   o.order_id
	from customers c
	join orders o on c.customer_id = o.customer_id
)
select customer_name,
	   customer_id,
	   count(distinct order_id) as total_order
from repeat_customer
group by 1,2
having count(distinct order_id) > 1
order by total_order desc;

---Loss-making products

with product_profit as(
	select p.product_id,
	  	   p.product_name,
	  	   sum(oi.profit) as total_pofit,
	   	   sum(oi.sales) as total_sales
	 from order_items oi
	 join products p on oi.product_id = p.product_id
	 group by 1,2
)
select product_id,
	   product_name,
	   total_pofit,
	   total_sales
from product_profit
where total_pofit < 0
order by total_pofit desc;


								-----* ADVANCED *-----

---Percentage contribution of each category to total sales

select p.category,
	   sum(oi.sales) as category_sales,
	   round(sum(oi.sales) * 100.0 / sum(sum(oi.sales)) over(), 2) as percentage_contribution
from order_items oi
join products p on oi.product_id = p.product_id
group by p.category
order by percentage_contribution desc;

---Year-over-year sales growth

with yearly_sales as (
    select
        extract(year from o.order_date) as sales_year,
        sum(oi.sales) as total_sales
    from orders o
    join order_items oi
        on o.order_id = oi.order_id
    group by extract(year from o.order_date)
)
select
    sales_year,
    total_sales,
    lag(total_sales) over (order by sales_year) as prev_year_sales,
    ROUND(
        (total_sales - lag(total_sales) over (order by sales_year)) * 100.0
        / lag(total_sales) over (order by sales_year),2) as yoy_growth_percent
from yearly_sales
order by sales_year;

---Pareto analysis (Top 20% customers)

with customer_sales as (
    select
        c.customer_id,
        c.customer_name,
        sum(oi.sales) as total_sales
    from customers c
    join orders o on c.customer_id = o.customer_id
    join order_items oi on o.order_id = oi.order_id
    group by c.customer_id, c.customer_name
),
ranked_customers AS (
    select
        *,
        NTILE(5) OVER (ORDER BY total_sales DESC) AS sales_bucket
    from customer_sales
)
select
    customer_id,
    customer_name,
    total_sales
from ranked_customers
WHERE sales_bucket = 1
ORDER BY total_sales DESC;

---Identify churned customers

WITH last_order AS (
    SELECT
        c.customer_id,
        c.customer_name,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    last_order_date
FROM last_order
WHERE last_order_date < CURRENT_DATE - INTERVAL '6 months'
   OR last_order_date IS NULL
ORDER BY last_order_date;
