---- Change over time trends ----

--- Sales over time performance

-- over day
SELECT order_date as order_day, SUM(sales_amount) as total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date

-- over year
SELECT EXTRACT(YEAR FROM order_date) as year, SUM(sales_amount) as total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY EXTRACT(YEAR FROM order_date)

-- we see increase in sales, are we gaining customers? and is each customer giving more sales?
SELECT EXTRACT(YEAR FROM order_date) AS year,
SUM(sales_amount) as total_sales,
COUNT (DISTINCT customer_key) AS num_of_cust,
SUM(sales_amount) / COUNT (DISTINCT customer_key) AS sales_per_dist_cust
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY EXTRACT(YEAR FROM order_date)
--- good for strategeic decisions

-- aggregating by month to see seasonality
SELECT EXTRACT(MONTH FROM order_date) AS month,
SUM(sales_amount) as total_sales,
COUNT (DISTINCT customer_key) AS num_of_cust,
SUM(sales_amount) / COUNT (DISTINCT customer_key) AS sales_per_dist_cust
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY EXTRACT(MONTH FROM order_date)

--- Thoughts: chrismas period, increase propensity to spend


-- Year and month
SELECT 
EXTRACT(year FROM order_date) AS year,
EXTRACT(MONTH FROM order_date) AS month,
SUM(sales_amount) as total_sales,
COUNT (DISTINCT customer_key) AS num_of_cust,
SUM(sales_amount) / COUNT (DISTINCT customer_key) AS sales_per_dist_cust
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(year FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY EXTRACT(year FROM order_date), EXTRACT(MONTH FROM order_date)

SELECT 
DATE_TRUNC('month', order_date)::DATE AS order_date, -- ::DATE converts timestamp to date format.
SUM(sales_amount) as total_sales,
COUNT (DISTINCT customer_key) AS num_of_cust,
SUM(sales_amount) / COUNT (DISTINCT customer_key) AS sales_per_dist_cust
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date) 
ORDER BY DATE_TRUNC('month', order_date) 