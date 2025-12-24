-- Cumulative Analysis
--- Helps to udnerstand whether business is growing or declining
---- eg running total sales by year or moving average of sales by month

---- so we need window functions!

---- TASK: calculate the total sales per month 
---- and then the running total of sales over time

SELECT 
DATE_TRUNC('month',order_date)::DATE as order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month',order_date)
ORDER BY order_date

-- Using Window Functions...
SELECT
order_date,
total_sales,
SUM(total_sales) OVER ( ORDER BY order_date) AS total_running_sales
FROM(
	SELECT 
	DATE_TRUNC('month',order_date)::DATE as order_date,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATE_TRUNC('month',order_date)
	ORDER BY order_date
)

-- with partitions tos see culmulative increase partitioned by year
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY year_ ORDER BY order_date) AS total_running_sales
FROM(
	SELECT 
	DATE_TRUNC('month',order_date)::DATE as order_date,
	SUM(sales_amount) AS total_sales,
	EXTRACT(year FROM order_date) AS year_
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATE_TRUNC('month',order_date),EXTRACT(year FROM order_date)
	ORDER BY order_date
)


-- moving average price and the quantity for that month
SELECT
order_date,
AVG(average_sales) OVER (
PARTITION BY year_ 
ORDER BY order_date) AS moving_average_sales,
total_quantity
FROM(
	SELECT 
	DATE_TRUNC('month',order_date)::DATE AS order_date,
	AVG(sales_amount) AS average_sales,
	EXTRACT(year FROM order_date) AS year_,
	SUM(quantity) as total_quantity
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATE_TRUNC('month',order_date),EXTRACT(year FROM order_date)
	ORDER BY order_date
)


SELECT sum(quantity) from gold.fact_sales