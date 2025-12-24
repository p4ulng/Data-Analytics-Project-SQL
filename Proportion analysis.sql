-- Part to Whole analysis (Of the form [measure]/total*100)
--- answers the question what contribute then most given a category.

--- Example:
--- What category contributes to the most overall sales
WITH category_sales AS(
SELECT
p.category,
SUM(sales_amount) AS Category_sum
FROM
gold.fact_sales f LEFT JOIN gold.dim_products p ON f.product_key=p.product_key
WHERE
order_date IS NOT NULL
GROUP BY p.category
)
SELECT
category,
Category_sum,
SUM(Category_sum) OVER() AS overall_sales,
CONCAT(ROUND(100*(Category_sum / SUM(Category_sum) OVER()),2),'%') AS Percentage_contri
FROM category_sales
ORDER BY Category_sum DESC

-- scary as business model heavily relies on bikes for sales and profits
-- we can see the over-performers and underperformers



-- want to see how the percentage changes over the years
WITH category_sales AS(
SELECT
p.category,
SUM(sales_amount) AS Category_sum_yearly,
EXTRACT ('year' FROM order_date) as year_
FROM
gold.fact_sales f LEFT JOIN gold.dim_products p ON f.product_key=p.product_key
WHERE
order_date IS NOT NULL
GROUP BY p.category,year_
ORDER BY p.category,year_
)
SELECT
year_,
category,
Category_sum_yearly,
SUM(Category_sum_yearly) OVER() AS overall_sales,
CONCAT(ROUND(100*(Category_sum_yearly / SUM(Category_sum_yearly) OVER(PARTITION BY year_)),2),'%') AS Percentage_contri
FROM category_sales
ORDER BY year_ DESC