-- Fact order table
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Fact_order` AS
SELECT *
FROM `olist-e-commerce-492009.Staging_data.Staging_order`

-- Fact review table summary by order 
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Fact_order_review_summary` AS
SELECT *
FROM `olist-e-commerce-492009.Staging_data.Staging_order_review_summary`

-- Fact review table 
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Fact_order_review` AS
SELECT *
FROM `olist-e-commerce-492009.Staging_data.Staging_order_review`

-- Fact payment table
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Fact_order_payment` AS
SELECT *
FROM `olist-e-commerce-492009.Raw_data.Raw_order_payment`

-- Fact order item table
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Fact_order_items` AS
SELECT *
FROM `olist-e-commerce-492009.Staging_data.Staging_order_items`

-- Dim product table
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Dim_product` AS
SELECT *
FROM `olist-e-commerce-492009.Staging_data.Staging_products`

-- Dim customer table
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Dim_customer` AS
SELECT *
FROM `olist-e-commerce-492009.Staging_data.Staging_customer`

-- Dim seller table
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Dim_seller` AS
SELECT *
FROM `olist-e-commerce-492009.Staging_data.Staging_seller`

-- Dim geolocation table
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Dim_geolocation` AS
SELECT *
FROM `olist-e-commerce-492009.Raw_data.Raw_geolocation_created`

-- Fact route table
CREATE OR REPLACE TABLE `olist-e-commerce-492009.Final_data.Fact_route` AS
SELECT *
FROM `olist-e-commerce-492009.Staging_data.Staging_route`
