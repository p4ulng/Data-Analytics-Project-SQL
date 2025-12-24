--- data segmentation; group data based on a specific range
--- understand the correlation between 2 measures
--- FORM: measure by measure, example total pdts by sales range

--- TASK: Segment products into cost ranges and count how many products fall
-- into each segment
WITH product_segments AS(
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM
gold.dim_products
)
SELECT
cost_range,
COUNT(product_key) 
FROM product_segments
GROUP BY cost_range
ORDER BY cost_range DESC


---TAKS group customers into three segments based on spending behavior
-- VIP: at least 12 months of history and spend more than 5000
-- Regular: at least 12 months of history but spending 5000 or less
-- New: lifespan less than 12 months
--- Find total number of customers by each group

WITH customer_spending AS(
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
EXTRACT(YEAR FROM AGE(MAX(order_date),MIN(order_date)))*12 +
EXTRACT(MONTH FROM AGE(MAX(order_date),MIN(order_date))) AS lifespan
FROM
gold.fact_sales f LEFT JOIN gold.dim_customers c on f.customer_key=c.customer_key
WHERE order_date IS NOT NULL
GROUP BY c.customer_key
)
SELECT
customer_key,
total_spending,
lifespan,
CASE WHEN lifespan >= 12 and total_spending > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 and total_spending <= 5000 THEN 'Regular'
	 ELSE 'New'
END cust_segment
FROM customer_spending
ORDER BY lifespan DESC,total_spending DESC



--find the total number per group
WITH customer_spending AS(
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
EXTRACT(YEAR FROM AGE(MAX(order_date),MIN(order_date)))*12 +
EXTRACT(MONTH FROM AGE(MAX(order_date),MIN(order_date))) AS lifespan
FROM
gold.fact_sales f LEFT JOIN gold.dim_customers c on f.customer_key=c.customer_key
WHERE order_date IS NOT NULL
GROUP BY c.customer_key
)
SELECT
CASE WHEN lifespan >= 12 and total_spending > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 and total_spending <= 5000 THEN 'Regular'
	 ELSE 'New'
END cust_segment,
COUNT(customer_key) AS customer_count
FROM customer_spending
GROUP BY cust_segment
ORDER BY customer_count DESC


--- NOTE that datediff in other sql types count month boundaries while age count full months
--- use datediff for billing cycles and reporting periods
--- below is the datediff equivalent
WITH customer_spending AS(
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
(
  DATE_PART('year', MAX(order_date)) * 12 + DATE_PART('month', MAX(order_date))
) -
(
  DATE_PART('year', MIN(order_date)) * 12 + DATE_PART('month', MIN(order_date))
) AS lifespan
FROM
gold.fact_sales f LEFT JOIN gold.dim_customers c on f.customer_key=c.customer_key
WHERE order_date IS NOT NULL
GROUP BY c.customer_key
)
SELECT
CASE WHEN lifespan >= 12 and total_spending > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 and total_spending <= 5000 THEN 'Regular'
	 ELSE 'New'
END cust_segment,
COUNT(customer_key) AS customer_count
FROM customer_spending
GROUP BY cust_segment
ORDER BY customer_count DESC

