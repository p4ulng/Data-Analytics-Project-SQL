-- Customer report
--- collect exploration and analysis into one big script.
--- create some requirements for reports
-- Purpose:
--     - This report consolidates key customer metrics and behaviors

-- Highlights:
--     1. Gathers essential fields such as names, ages, and transaction details.
--     2. Aggregates customer-level metrics:
-- 	   - total orders
-- 	   - total sales
-- 	   - total quantity purchased
-- 	   - total products
-- 	   - lifespan (in months)
--     3. Segments customers into categories (VIP, Regular, New) and age groups.
--     4. Calculates valuable KPIs:
-- 	    - recency (months since last order)
-- 		- average order value
-- 		- average monthly spend


CREATE VIEW gold.report_customers AS
WITH base_query AS (
-- Base Query: collect core columns from the tables (we solve point 1)
	SELECT
	f.order_number,
	f.quantity,
	f.customer_key,
	f.order_date,
	f.product_key,
	f.sales_amount,
	c.customer_number,
	CONCAT(c.first_name,' ',c.last_name) AS customer_name, --do transformations as needed
	EXTRACT(YEAR FROM AGE(CURRENT_DATE,c.birthdate)) AS age
	FROM gold.fact_sales f LEFT JOIN gold.dim_customers c
	ON c.customer_key=f.customer_key
	WHERE order_date IS NOT NULL AND birthdate IS NOT NULL
)
, customer_aggregation AS(
SELECT 
-- 2. Aggregates customer-level metrics:
	customer_name,
	customer_number,
	customer_key,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT product_key) AS total_products,
	SUM(quantity) AS total_quantity,
	(
	  DATE_PART('year', MAX(order_date)) * 12 + DATE_PART('month', MAX(order_date))
	) -
	(
	  DATE_PART('year', MIN(order_date)) * 12 + DATE_PART('month', MIN(order_date))
	) AS lifespan,
	MAX(order_date) AS last_order_date
FROM base_query
GROUP BY 
	customer_name,
	customer_number,
	customer_key,
	age
)
SELECT 
	customer_name,
	customer_number,
	customer_key,
	age,
	CASE WHEN age<20 THEN 'Under 20'
		 WHEN age BETWEEN 20 and 29 THEN '20-29'
		 WHEN age BETWEEN 30 and 39 THEN '30-39'
		 WHEN age BETWEEN 40 and 49 THEN '40-49'
		 ELSE '50 and Above'
	END age_group,
	total_products,
	lifespan,
	CASE WHEN lifespan >=12 and total_sales>5000 THEN 'VIP'
		 WHEN lifespan >=12 and total_sales<5000 THEN 'Regular'
		 ELSE 'New'
	END customer_cat,
	last_order_date,
	(
	  DATE_PART('year', CURRENT_DATE) * 12 + DATE_PART('month', CURRENT_DATE)
	) -
	(
	  DATE_PART('year', last_order_date) * 12 + DATE_PART('month', last_order_date)
	)  AS recency,
	total_sales,
	total_orders,
	-- -- compute average order value(AVO)
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales/total_orders 
	END avg_order_value,
	-- -- compute average monthly spending (AMS)
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales/lifespan::INT
	END avg_month_spending
FROM customer_aggregation











-- checking for division by zero
-- WITH base_query AS (
-- -- Base Query: collect core columns from the tables (we solve point 1)
-- 	SELECT
-- 	f.order_number,
-- 	f.quantity,
-- 	f.customer_key,
-- 	f.order_date,
-- 	f.product_key,
-- 	f.sales_amount,
-- 	c.customer_number,
-- 	CONCAT(c.first_name,' ',c.last_name) AS customer_name,
-- 	EXTRACT(YEAR FROM AGE(CURRENT_DATE,c.birthdate)) AS age
-- 	FROM gold.fact_sales f LEFT JOIN gold.dim_customers c
-- 	ON c.customer_key=f.customer_key
-- 	WHERE order_date IS NOT NULL AND birthdate IS NOT NULL
-- )
-- , customer_aggregation AS(
-- SELECT 
-- -- 2. Aggregates customer-level metrics:
-- 	customer_name,
-- 	customer_number,
-- 	customer_key,
-- 	age,
-- 	COUNT(DISTINCT order_number) AS total_orders,
-- 	SUM(sales_amount) AS total_sales,
-- 	COUNT(DISTINCT product_key) AS total_products,
-- 	SUM(quantity) AS total_quantity,
-- 	(
-- 	  DATE_PART('year', MAX(order_date)) * 12 + DATE_PART('month', MAX(order_date))
-- 	) -
-- 	(
-- 	  DATE_PART('year', MIN(order_date)) * 12 + DATE_PART('month', MIN(order_date))
-- 	) AS lifespan,
-- 	MAX(order_date) AS last_order_date
-- FROM base_query
-- GROUP BY 
-- 	customer_name,
-- 	customer_number,
-- 	customer_key,
-- 	age
-- )
-- SELECT DISTINCT total_orders
-- FROM customer_aggregation



-- now we can put it in database as a view and connect it to a dashboard
--- We try to get the report
SELECT * FROM gold.report_customers