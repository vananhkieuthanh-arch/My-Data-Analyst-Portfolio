SELECT * FROM `olist-e-commerce-492009.Staging_data.Staging_order` LIMIT 100
SELECT * FROM `olist-e-commerce-492009.Staging_data.Staging_order_items` LIMIT 100

-- DATA CLEANING
-- Checking NULL --> No NULL value in key fields
SELECT *
FROM `olist-e-commerce-492009.Staging_data.Staging_order`
WHERE order_id IS NULL
      OR customer_id IS NULL
      OR order_status IS NULL

-- Checking duplicate order --> No duplicate order
SELECT order_id, COUNT(*) AS cnt
FROM `olist-e-commerce-492009.Staging_data.Staging_order`
GROUP BY order_id
HAVING COUNT(*) > 1

-- EDA
-- Total time
SELECT MAX(order_purchase_timestamp), MIN(order_purchase_timestamp)
FROM `olist-e-commerce-492009.Raw_data.Raw_order_2`


-- Total orders
SELECT COUNT(DISTINCT(order_id)) AS total_order
FROM `olist-e-commerce-492009.Staging_data.Staging_order`

-- Total revenue
SELECT SUM(item.order_value) AS total_revenue
FROM `olist-e-commerce-492009.Staging_data.Staging_order` AS ord
LEFT JOIN `olist-e-commerce-492009.Staging_data.Staging_order_items` AS item
ON ord.order_id = item.order_id
WHERE ord.order_status = 'delivered'


-- Late Delivery Rate Calculation
WITH late_orders AS (
  SELECT COUNT(DISTINCT order_id) AS total_late_order
  FROM `olist-e-commerce-492009.Staging_data.Staging_order`
  WHERE order_status = 'delivered'
    AND is_delayed = 1
),

delivered_orders AS (
  SELECT COUNT(DISTINCT order_id) AS total_delivered_order
  FROM `olist-e-commerce-492009.Staging_data.Staging_order`
  WHERE order_status = 'delivered'
)

SELECT 
  total_late_order, 
  total_delivered_order,
  ROUND(SAFE_DIVIDE(total_late_order, total_delivered_order)*100,2) AS late_delivery_rate
FROM late_orders, delivered_orders;

-- Avg Delivery Days
SELECT ROUND(AVG(leadtime),2) AS Avg_leadtime
FROM `olist-e-commerce-492009.Staging_data.Staging_order`
WHERE order_status = "delivered"

-- Avg Review Score
SELECT ROUND(AVG(avg_review_score),2) AS avg_review_score
FROM `olist-e-commerce-492009.Staging_data.Staging_order` 


-- 5.	Monthly Orders & Revenue Trend
WITH order_revenue AS (
  -- Step 1: Aggregate revenue at the order level first
  SELECT 
    order_id, 
    SUM(order_value) AS revenue
  FROM `olist-e-commerce-492009.Staging_data.Staging_order_items`
  GROUP BY order_id
)

SELECT 
    -- We keep the Month_Num for sorting purposes
    EXTRACT(MONTH FROM ord.order_purchase_timestamp) AS Month_Num,
    FORMAT_DATE('%m', ord.order_purchase_timestamp) AS Month,
    COUNT(DISTINCT ord.order_id) AS Monthly_order,
    -- Formatting revenue: divide, round, cast, and add suffix
    CONCAT(CAST(ROUND(SUM(rev.revenue) / 1000, 2) AS STRING), 'K') AS Monthly_revenue 
FROM `olist-e-commerce-492009.Staging_data.Staging_order` AS ord
LEFT JOIN order_revenue AS rev 
  ON ord.order_id = rev.order_id
GROUP BY 
    EXTRACT(MONTH FROM ord.order_purchase_timestamp), 
    FORMAT_DATE('%m', ord.order_purchase_timestamp)
ORDER BY 
    Month_Num ASC;

-- On-time vs Late Delivery Trend
SELECT EXTRACT(MONTH FROM order_delivered_customer_date) AS Month_Num, 
    is_delayed, 
    COUNT(DISTINCT order_id) AS order_count
FROM `olist-e-commerce-492009.Staging_data.Staging_order` 
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY 
    Month_Num, 
    is_delayed
ORDER BY 
    Month_Num ASC, 
    is_delayed ASC;

-- Orders by Customer State
SELECT cus.customer_state, COUNT(DISTINCT(ord.order_id)) AS total_order
FROM `olist-e-commerce-492009.Staging_data.Staging_order` AS ord
LEFT JOIN `olist-e-commerce-492009.Raw_data.Raw_customer` AS cus
ON ord.customer_id = cus.customer_id 
GROUP BY cus.customer_state

-- Top Categories by Revenue
SELECT cate.product_category_name, SUM(item.order_value) AS cate_rev
FROM `olist-e-commerce-492009.Staging_data.Staging_order` AS ord
LEFT JOIN `olist-e-commerce-492009.Staging_data.Staging_order_items` AS item
  ON ord.order_id = item.order_id
LEFT JOIN `olist-e-commerce-492009.Raw_data.Raw_products` AS cate
  ON item.product_id = cate.product_id
GROUP BY cate.product_category_name
ORDER BY cate_rev DESC



