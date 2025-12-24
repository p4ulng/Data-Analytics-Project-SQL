--- product report
--- report to consolidate key product metrics and behaviors.

--- Highlights:
--     1. Gather essential fields like product name , category, subcategory
--     2. Aggregates product-level metrics:
-- 	   - total orders
-- 	   - total sales
-- 	   - total quantity sold
-- 	   - total customers(unique)
-- 	   - lifespan (in months)
--     3. Segments products by revenue to identify High-Performers, Mid-range or Low
--     4. Calculates valuable KPIs:
-- 	    - recency (months since last order)
-- 		- average order revenue
-- 		- average monthly revenue

CREATE VIEW gold.products_report AS 
WITH base_query AS(
	SELECT
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.start_date,
	f.order_number,
	f.order_date,
	p.cost,
	f.sales_amount,
	f.quantity,
	f.customer_key
	FROM
	gold.fact_sales f 
	LEFT JOIN gold.dim_products p 
	ON f.product_key=p.product_key
	WHERE order_date IS NOT NULL
)
, product_agg AS(
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT customer_key) AS total_unique_customers,
	MAX(order_date) AS last_sale_date,
	( 
		DATE_PART('year',MAX(order_date))*12 + DATE_PART('month',MAX(order_date))
	) -
	(
		DATE_PART('year',MIN(order_date))*12 + DATE_PART('month',MIN(order_date))
	) AS lifespan
FROM
base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	total_orders,
	total_sales,
	total_quantity,
	total_unique_customers,
	last_sale_date,
	lifespan,
	CASE WHEN total_sales>50000 THEN 'High-performer'
		 WHEN total_sales>=10000 THEN 'Mid-range'
		 ELSE 'Poor performer'
	END product_segments,
	( 
		DATE_PART('year',CURRENT_DATE)*12 + DATE_PART('month', CURRENT_DATE)
		) -
	(
		DATE_PART('year',last_sale_date)*12 + DATE_PART('month',last_sale_date)
	) as recency,
	CASE WHEN total_quantity = 0 THEN total_sales
		 ELSE total_sales/total_quantity 
	END average_order_revenue,
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales/lifespan::INT 
	END average_monthly_revenue
FROM 
product_agg


SELECT
* FROM gold.products_report