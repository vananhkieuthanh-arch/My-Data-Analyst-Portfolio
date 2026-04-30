# Olist Brazilian E-Commerce Public

**Description:** This project analyzes appox. 100,000 rows of order data from 2016 to 2018 using Google BigQuery and built into an interactive dashboard with Power BI to provided insights into Olist’s e-commerce performance across all areas: sales, customer satisfaction, and delivery operations. The dashboard helps identify key revenue drivers categories, regions, customer experience patterns, and Delivery performance to support business decision-making for managment & growth strategies, logistics & performance.

**Tools:** Google BigQuery, Power Query and Power BI.

**Skills:** 
- SQL (Google BigQuery): structured data pipeline with staging & final tables, data cleaning & EDA, JOINs, aggregations, datetime transformation, CASE WHEN, subqueries & CTEs, window functions, calculated fields, and Delivery KPI computation for business analysis.
- Power Query: Transform data before loading into Power BI including add/remove columns, change data types, split columns, segmentation
- Power BI: Data modelling, DAX measures, KPI cards, YoY comparison, slicers, dynamic filtering, TopN selection, cumulative revenue analysis, delivery performance tracking, route-level analysis, conditional formatting, data visualization, dashboard storytelling.

**Outputs:**  
- Detailed SQL scripts with in-line comments in `.sql` format.
- Interactive dashboards uploaded on `Power BI Public` (best viewed in full screen mode).

## Datasets
- `olist_orders_dataset.csv` - detailed order information (order ID, customer ID, delivery leadtime)
  - Fields: 11  
  - Records: 99,433
- `olist_order_items_dataset.csv` - Detailed order item, value & seller ID
  - Fields: 7  
  - Records: 112,650
- `olist_order_reviews_dataset.csv` - Customer review score per order
  - Fields: 7  
  - Records: 99,224
- Others: Master data of seller, customer, product & category
  - `olist_sellers_dataset.csv`
  - `olist_customers_dataset.csv`
  - `product_category_name_translation.csv`
  - `olist_products_dataset.csv`

## Acknowledgements
The data can be downloaded from Kaggle: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce.

## Dashboard
Dashboard link: 

![Image Alt](https://github.com/vananhkieuthanh-arch/Olist-Brazilian-E-Commerce-Public/blob/159695f50de6fc91237489c81befdfce6561f4e2/Screenshot/Page%201%20Executive%20Summary.png)

![Image Alt](https://github.com/vananhkieuthanh-arch/Olist-Brazilian-E-Commerce-Public/blob/159695f50de6fc91237489c81befdfce6561f4e2/Screenshot/Page%202%20Sales%20Performance.png)

![Image Alt](https://github.com/vananhkieuthanh-arch/Olist-Brazilian-E-Commerce-Public/blob/159695f50de6fc91237489c81befdfce6561f4e2/Screenshot/Page%203%20Customer%20Review.png)

![Image Alt](https://github.com/vananhkieuthanh-arch/Olist-Brazilian-E-Commerce-Public/blob/159695f50de6fc91237489c81befdfce6561f4e2/Screenshot/Page%204%20Delivery%20Review.png)
