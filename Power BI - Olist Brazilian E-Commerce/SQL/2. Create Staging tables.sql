-- Create Staging_order: Remove delivered orders but don't have actual delivery date (8 orders) & Add in delay_days for delivered orders & Classify late / not late delivery order, add in seller_id
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Staging_data.Staging_order` AS
WITH order_base AS (
    SELECT 
        *,
        DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY) AS leadtime,
        DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) AS delay_days
    FROM `olist-e-commerce-492009.Raw_data.Raw_order_2`
    WHERE NOT (
      order_status = 'delivered' 
      AND (
        order_delivered_customer_date IS NULL 
        OR order_estimated_delivery_date IS NULL 
        OR order_purchase_timestamp IS NULL
      )
    )
),
-- Deduplicate items so we only have one seller per order_id
unique_order_items AS (
    SELECT 
        order_id        , 
        seller_id
    FROM (
        SELECT 
            order_id, 
            seller_id,
            ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY shipping_limit_date ASC) as rank
        FROM `olist-e-commerce-492009.Raw_data.Raw_order_items`
    )
    WHERE rank = 1
)

SELECT 
    ob.*,
    IF(ob.delay_days > 0, 1, 0) AS is_delayed,
    -- uoi.seller_id
FROM order_base AS ob
LEFT JOIN unique_order_items AS uoi 
  ON ob.order_id = uoi.order_id;

-- Create Staging_order_items: Add in order_value = price + freight value
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Staging_data.Staging_order_items` AS
SELECT 
    *, 
    (price + freight_value) AS order_value,
FROM `olist-e-commerce-492009.Raw_data.Raw_order_items`;

-- Create Staging_product_category_english: Make 1st row as header
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Staging_data.Staging_product_category_translation` AS
SELECT
  string_field_0 AS product_category_name,
  string_field_1 AS product_category_name_english
FROM `olist-e-commerce-492009.Raw_data.Raw_product_category_translation`;


CREATE OR REPLACE TABLE `olist-e-commerce-492009.Staging_data.Staging_products` AS
SELECT prod.*, prodE.product_category_name_english
FROM `olist-e-commerce-492009.Raw_data.Raw_products` AS prod
JOIN `olist-e-commerce-492009.Staging_data.Staging_product_category_translation` AS prodE
ON prod.product_category_name = prodE.product_category_name;

-- Create Staging_order_review_summary: Only order_id, average score
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Staging_data.Staging_order_review` AS
SELECT order_id, review_score
FROM `olist-e-commerce-492009.Raw_data.Raw_order_reviews_2`

-- Create Staging_order_review
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Staging_data.Staging_order_review_summary` AS
SELECT order_id, AVG(review_score) AS review_score
FROM `olist-e-commerce-492009.Raw_data.Raw_order_reviews_2`
GROUP BY order_id

-- Create Staging_customer
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Staging_data.Staging_customer` AS
(
  WITH cus AS (
    SELECT DISTINCT
      CAST(customer_id AS STRING) AS customer_id,
      TRIM(customer_city) AS customer_city,
      TRIM(customer_state) AS customer_state
    FROM `olist-e-commerce-492009.Raw_data.Raw_customer`
    WHERE customer_id IS NOT NULL 
      AND customer_city IS NOT NULL 
      AND customer_state IS NOT NULL
  ),
  -- Deduplicate the geo table so there is only 1 row per state abbreviation
  geo_unique AS (
    SELECT DISTINCT 
      string_field_0 AS state_abbr, 
      string_field_1 AS state_name, 
      string_field_2 AS region 
    FROM `olist-e-commerce-492009.Raw_data.Raw_geolocation_created`
  )

  SELECT 
    cus.*,
    geo_unique.state_name,
    geo_unique.region 
  FROM cus
  LEFT JOIN geo_unique -- Use LEFT JOIN to ensure no customers are dropped
    ON cus.customer_state = geo_unique.state_abbr
);

-- Create Staging_seller
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Staging_data.Staging_seller` AS
(
  WITH sel AS (
    SELECT DISTINCT
      CAST(seller_id AS STRING) AS seller_id,
      TRIM(seller_city) AS seller_city,
      TRIM(seller_state) AS seller_state
    FROM `olist-e-commerce-492009.Raw_data.Raw_sellers`
    WHERE seller_id IS NOT NULL 
      AND seller_city IS NOT NULL 
      AND seller_state IS NOT NULL
  ),
  -- Deduplicate the geo table so there is only 1 row per state abbreviation
  geo_unique AS (
    SELECT DISTINCT 
      string_field_0 AS state_abbr, 
      string_field_1 AS state_name, 
      string_field_2 AS region 
    FROM `olist-e-commerce-492009.Raw_data.Raw_geolocation_created`
  )

  SELECT 
    sel.*,
    geo_unique.state_name,
    geo_unique.region 
  FROM sel
  LEFT JOIN geo_unique -- Use LEFT JOIN to ensure no customers are dropped
    ON sel.seller_state = geo_unique.state_abbr
);

-- Create Staging_Route
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Staging_data.Staging_route` AS
(
WITH 
      cus AS (
            SELECT DISTINCT *
            FROM olist-e-commerce-492009.Staging_data.Staging_customer
            ),
      
      sel AS (
            SELECT DISTINCT *
            FROM olist-e-commerce-492009.Staging_data.Staging_seller
            ),

      ord AS (
            SELECT ord.order_id, ord.customer_id, it.seller_id
            FROM olist-e-commerce-492009.Staging_data.Staging_order AS ord
            JOIN olist-e-commerce-492009.Staging_data.Staging_order_items AS it
            ON ord.order_id = it.order_id)

SELECT DISTINCT
      customer_city,
      customer_state,
      cus.state_name AS customer_state_name,
      cus.region AS customer_region,
      seller_city,
      seller_state,
      sel.state_name AS seller_state_name,
      sel.region AS seller_region,
    -- City Route (e.g., "sao paulo → boa vista")
    CONCAT(seller_city, ' → ', customer_city) AS city_route,

    -- State Route (e.g., "SP → RR")
    CONCAT(seller_state, ' → ', customer_state) AS state_route,
    
    -- Region Route (e.g., "Southeast → North")
    CONCAT(sel.region, ' → ',  cus.region) AS region_route,
      
FROM ord
LEFT JOIN cus ON ord.customer_id = cus.customer_id
LEFT JOIN sel ON ord.seller_id = sel.seller_id
)


