-- A. Pizza Metrics
-- How many pizzas were ordered?
-- How many unique customer orders were made?
-- How many successful orders were delivered by each runner?
-- How many of each type of pizza was delivered?
-- How many Vegetarian and Meatlovers were ordered by each customer?
-- What was the maximum number of pizzas delivered in a single order?
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- How many pizzas were delivered that had both exclusions and extras?
-- What was the total volume of pizzas ordered for each hour of the day?
-- What was the volume of orders for each day of the week?


-- How many pizzas were ordered?

select COUNT(*) as pizza_ordered
from customer_orders

-- How many unique customer orders were made?
select COUNT(DISTINCT order_id)
from customer_orders


-- How many successful orders were delivered by each runner?

select o.runner_id as runner,
COUNT(o.order_id) as order_count
from customer_orders c join runner_orders o
on c.order_id = o.order_id
where o.cancellation is NULL or o.cancellation = 'null' or o.cancellation = '' 
GROUP BY o.runner_id

-- How many of each type of pizza was delivered?

select c.pizza_id pizza_type,
COUNT(*) as delivered_pizza
from customer_orders c join runner_orders o
on c.order_id = o.order_id
where o.cancellation is NULL or o.cancellation = 'null' or o.cancellation = '' 
GROUP BY c.pizza_id


-- How many Vegetarian and Meatlovers were ordered by each customer?

select p.pizza_name as pizza_name, 
COUNT(*) as count_order
from customer_orders c join pizza_names p
on c.pizza_id = p.pizza_id
GROUP BY p.pizza_name


-- What was the maximum number of pizzas delivered in a single order?

select order_id ,
COUNT(*) order_count
from customer_orders
group by order_id
ORDER BY COUNT(*) DESC
LIMIT 1

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
    co.customer_id,
    SUM(CASE WHEN (COALESCE(co.exclusions, '') <> '' OR COALESCE(co.extras, '') <> '') THEN 1 ELSE 0 END) AS pizzas_with_changes,
    SUM(CASE WHEN (COALESCE(co.exclusions, '') = '' AND COALESCE(co.extras, '') = '') THEN 1 ELSE 0 END) AS pizzas_without_changes
FROM customer_orders co
JOIN runner_orders ro
  ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = ''
GROUP BY co.customer_id
ORDER BY co.customer_id;


-- How many pizzas were delivered that had both exclusions and extras?

with cte as(
select *
from customer_orders c join runner_orders o
on c.order_id = o.order_id
where o.cancellation is NULL or o.cancellation = 'null' or o.cancellation = '' 
)


select COUNT(*) as count
from cte
where (exclusions is not NULL and exclusions <> '' and exclusions <> 'null') 
AND (extras is not NULL and extras <> '' and extras <> 'null')

-- What was the total volume of pizzas ordered for each hour of the day?



select COUNT(order_id) pizza_count, extract(hour from order_time) as hours 
from customer_orders
group by hours




-- What was the volume of orders for each day of the week?

select COUNT(order_id) pizza_count,  EXTRACT(DOW FROM order_time)  as days 
from customer_orders
group by days
