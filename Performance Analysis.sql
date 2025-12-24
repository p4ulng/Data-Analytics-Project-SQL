--performance analysis
--- to compare current performance to target performance to measure success
--- so Current[Measure] - Target[Measure]


---- task: analyse the yearly performance of products by comparing
---- their average sales performance of the product and the previous
---- year's sales
WITH yearly_product_sales AS( -- use CTE here for better readability 
SELECT
EXTRACT ('year' FROM f.order_date) AS year_,
p.product_name,
SUM(f.sales_amount) AS yearly_sales
FROM 
	(gold.fact_sales f
	LEFT JOIN gold.dim_products p 
	ON f.product_key=p.product_key)
WHERE f.order_date IS NOT NULL
GROUP BY EXTRACT ('year'FROM f.order_date), p.product_name
)
SELECT
year_,
product_name,
yearly_sales,
AVG(yearly_sales) OVER (PARTITION BY product_name)::INT AS avg_sales, --we want avg prices of a product over the years so partion by product name
yearly_sales - AVG(yearly_sales) OVER (PARTITION BY product_name)::INT AS diff_avg, 
CASE WHEN yearly_sales - AVG(yearly_sales) OVER (PARTITION BY product_name)::INT > 0 THEN 'Above Avg'
	 WHEN yearly_sales - AVG(yearly_sales) OVER (PARTITION BY product_name)::INT < 0 THEN 'Below Avg'
	 ELSE 'Avg' --
END FLAG_avg_change,
--year over year analysis
LAG(yearly_sales,1) OVER (PARTITION BY y.product_name ORDER BY year_) AS prev_year_res,
yearly_sales - LAG(yearly_sales,1,yearly_sales) OVER (PARTITION BY y.product_name ORDER BY year_) AS year_to_year_change,
CASE WHEN yearly_sales - LAG(yearly_sales,1,yearly_sales) OVER (PARTITION BY y.product_name ORDER BY year_) > 0 THEN 'Increasing'
	 WHEN yearly_sales - LAG(yearly_sales,1,yearly_sales) OVER (PARTITION BY y.product_name ORDER BY year_) < 0 THEN 'Decreasing'
	 ELSE 'No Change' --
END FLAG_year_to_year
FROM yearly_product_sales y
ORDER BY product_name, year_