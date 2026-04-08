set search_path to 'Amazon_brazil';
select* from payments;
--Analysis-1

--Query-1-To analyse the average payment value of each payment type.
SELECT
payment_type,
cast(round(avg(payment_value)) as INTEGER) as avg_payment_value 
from payments 
group by payment_type 
order by avg_payment_value;

--Query-2-To analyse the percentage of total orders for each payment type.
SELECT payment_type,
round((count(order_id)*100)/sum(count(order_id)) over(),1) as order_percentage
from payments 
group by payment_type 
order by order_percentage desc;

--Query-3-To categorise the product category “smart” in the price range of 100 to 500 BRL
select p.product_id,o.price 
from product p join order_items o on p.product_id=o.product_id
where p.product_category_name='smart' and o.price between 100 and 500 order by o.price desc;

--Query-4-Analysis of top 3-months with the highest total sales value.
select TO_CHAR(o2.order_purchase_timestamp,'fmmonth') as month,
round(sum(o1.price+o1.freight_value),0) as total_sales 
from orders o2 join order_items o1 on o2.order_id=o1.order_id 
group by month 
order by total_sales desc limit 3;

--Query-5-To identify the categories where the difference between maximum and minimum product price greater than 500 BRL.
select p.product_category_name,(max(o.price)-min(o.price)) as price_difference
from product p join order_items o on p.product_id=o.product_id
group by p.product_category_name having (max(o.price)-min(o.price))>500 
order by price_difference desc; 

--Query-6-To check the consistency of the transaction of payment type by checking least variance in payment types.
select payment_type,stddev(payment_value) as std_deviation from payments 
group by payment_type order by std_deviation;

--Query-7-List of products which has missing category name or contain a single character.
select product_id,product_category_name from product
where product_category_name isnull or length(trim(product_category_name))=1;

--Analysis-2

--Query-1-To calculate the count of each payment type in three different order value segments(Low,Medium,High).
with OrderTotals as (
    
    select 
        order_id, 
        sum(payment_value) as total_value
    from 
        payments
    group by 
        order_id
),
Segments as (
    
    Select
        order_id,
        case 
            when total_value < 200 then 'Low (< 200)'
            when total_value between 200 and 1000 then 'Medium (200-1000)'
            else 'High (> 1000)'
        end as order_value_segment
    from 
        OrderTotals
)
Select 
    s.order_value_segment, 
    p.payment_type, 
    Count(*) as count
from
    payments p
join
    Segments s on p.order_id = s.order_id
group by
    s.order_value_segment, 
    p.payment_type
order by 
    case 
        when s.order_value_segment = 'Low (< 200)' then 1
        when s.order_value_segment = 'Medium (200-1000)' then 2
        else 3
    end asc,
    count desc;

--Query-2-To calculate the minimum and maximum and average price of each category.
select p.product_category_name,min(o.price),max(o.price),avg(o.price)as avg_price 
from product p join order_items o on p.product_id=o.product_id
group by p.product_category_name 
order by avg_price desc;

--Query-3-To analyse the customers who placed multiple orders over time.
select c.customer_unique_id,count(order_id) as total_orders 
from customers c join orders o on c.customer_id=o.customer_id 
group by c.customer_unique_id having count(o.order_id)>1 order by total_orders desc;

--Query-4-To analyse the customer order quantity into different types(New,Returning,Loyal).
create temporary table customer_order_summary as
select c.customer_unique_id,count(o.order_id)as order_qty 
from customers c join orders o on c.customer_id=o.customer_id group by customer_unique_id;

select customer_unique_id,
case
 when order_qty=1 then 'new'
 when order_qty between 2 and 4 then 'Returning'
 else 'loyal' 
 end as customer_type
from customer_order_summary

--Query-5-To identify product categories which generates highest revenue.
select p.product_category_name, sum(o.price+o.freight_value) as total_revenue 
from product p join order_items o on p.product_id=o.product_id
group by p.product_category_name order by total_revenue desc limit 5;

--Analysis-3

--Query-1-To compare the total sales pattern between different seasons.
select * from orders;
select * from order_items;

select season,sum(order_total) as total_sales
from(
select sum(o2.price) as order_total,
case
  when extract(month from o1.order_purchase_timestamp) in (3,4,5) then 'Spring'
  when extract(month from o1.order_purchase_timestamp) in (6,7,8) then 'Summer'
  when extract(month from o1.order_purchase_timestamp) in (9,10,11) then 'Autumn'
  else 'Winter' 
 end as season
from orders o1 join order_items o2 
on o1.order_id=o2.order_id
group by o1.order_purchase_timestamp
)
group by season
order by season;

--Query-2-To identify products that have sales volume above the overall average.
select product_id,sum(product_photos_qty) as total_quantity_sold 
from product 
group by product_id having sum(product_photos_qty)>
(select avg(product_photos_qty) from product);

--Query-3-To analyse the revenue generated in each month of 2018.
select extract(month from o1.order_purchase_timestamp) as month,sum(o2.price+o2.freight_value)
as total_revenue 
from orders o1 join order_items o2 on o1.order_id=o2.order_id 
where extract(year from o1.order_purchase_timestamp)=2018 
group by month order by month;

--Query-4-To create segmentation based on purchase frequency of customers.
with total_orders as
(
select customer_id,count(order_id) as order_count from orders group by customer_id
),
customer_segmentation as
(
select customer_id,
case
 when order_count between 1 and 2 then 'Occasinal'
 when order_count between 3 and 5 then 'Regular'
 else 'Loyal' 
 end as customer_type from total_orders
)
select customer_type,count(*) as count from customer_segmentation 
group by customer_type
order by count desc;

--Query-5-To identify customers with high ranking for exclusive rewards.
select  distinct o1.customer_id as customer_id,(sum(o2.price+o2.freight_value)/count(o1.order_id)) as 
average_order_value,dense_rank() over(partition by
(sum(o2.price+o2.freight_value)/count(o1.order_id))) as customer_rank 
from orders o1 join order_items o2 on o1.order_id=o2.order_id 
group by o1.customer_id limit 20; 

--Query-6-To calculate monthly cumulative sales for each product.
with recursive
indexed_sales as (
    Select 
        oi.product_id, 
        to_char(o.order_purchase_timestamp, 'YYYY-MM') as sale_month, 
        sum(oi.price) as monthly_revenue,
        row_number() over (
            partition by oi.product_id 
            order by to_char(o.order_purchase_timestamp, 'YYYY-MM')
        ) as rn
    from order_items oi
    join orders o on oi.order_id = o.order_id
    group by 1, 2
),


cumulative_sales as (
    
    Select
        product_id, 
        sale_month, 
        monthly_revenue as total_sales,
        rn
    from indexed_sales
    where rn = 1

    union all
	
    Select 
        i.product_id, 
        i.sale_month, 
        c.total_sales + i.monthly_revenue,
        i.rn
    from indexed_sales i
    join cumulative_sales c on i.product_id = c.product_id and i.rn = c.rn + 1
)
Select 
    product_id, 
    sale_month, 
    ROUND(cast(total_sales AS NUMERIC), 2) as total_sales
from cumulative_sales
order by product_id, sale_month desc;

--Query-7- to calculate monthly sales payment for each payment type and compute the percentage 
--change from previous month
with monthly_sales as (
    Select
        p.payment_type,
        date_trunc('month', o.order_purchase_timestamp) AS sale_month,
        sum(p.payment_value) AS monthly_total
    from orders o
    join payments p
       on o.order_id = p.order_id
    where o.order_purchase_timestamp >= DATE '2018-01-01'
      and o.order_purchase_timestamp <  DATE '2019-01-01'
    group by
        p.payment_type,
        DATE_TRUNC('month', o.order_purchase_timestamp)
),

monthly_growth AS (
    Select
        payment_type,
        sale_month,
        monthly_total,
        lag(monthly_total) over (
            partition by payment_type
            order by sale_month
        ) as previous_month_total
    from monthly_sales
)

Select
    payment_type,
    sale_month,
    monthly_total,
    round(
        (monthly_total - previous_month_total) * 100.0
        / nullif(previous_month_total, 0),
        2
    ) as monthly_change
from monthly_growth
order by
    payment_type,
    sale_month;







