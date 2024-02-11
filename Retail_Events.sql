Use retail_events_db;

-- Analysing the tables

SELECT * FROM dim_camapigns;
SELECT * FROM dim_products;
SELECT * FROM dim_stores;
SELECT * FROM fact_events;


-- 1. List of products with a base price grater than 500, featured in promo type "BOGOF"

SELECT DISTINCT
    dim_products.product_name,
    fact_events.promo_type,
    fact_events.base_price
FROM
    dim_products
        INNER JOIN
    fact_events ON dim_products.product_code = fact_events.product_code
WHERE
    base_price > 500
        AND promo_type = 'BOGOF';


-- 2. Cities with the highest store presence.

SELECT 
    COUNT(city) AS Total_count, city
FROM
    dim_stores
GROUP BY city
ORDER BY Total_count DESC;


-- 3. Total Revenue generated before and after the campaign.

SELECT 
    dim_campaigns.campaign_name,
    SUM(fact_events.base_price * quantity_sold_before_promo) / 1000000 AS 'Revenue_before_campaign(millions)',
    SUM(fact_events.base_price * quantity_sold_after_promo) / 1000000 AS 'Revenue_after_campaign(millions)'
FROM
    fact_events
        INNER JOIN
    dim_campaigns ON fact_events.campaign_id = dim_campaigns.campaign_id
GROUP BY dim_campaigns.campaign_name;


-- 4. Pecentage of Qauntity Sold for each category.

SELECT 
    category,
    (SUM(quantity_sold_after_promo) - SUM(quantity_sold_before_promo)) / SUM(quantity_sold_before_promo) * 100 AS 'ISU%',
    RANK() over( ORDER BY (SUM(quantity_sold_after_promo) - SUM(quantity_sold_before_promo)) / SUM(quantity_sold_before_promo) DESC) AS rank_order
FROM
    fact_events
        INNER JOIN
    dim_campaigns ON fact_events.campaign_id = dim_campaigns.campaign_id
        INNER JOIN
    dim_products ON fact_events.product_code = dim_products.product_code
WHERE
    campaign_name = 'Diwali'
GROUP BY category;

-- 5.  Top 5 products, ranked by Incremental Revenue Percentage(IR%), across all campaigns.

SELECT 
	category,
	product_name, (SUM(base_price*quantity_sold_after_promo) - SUM(base_price*quantity_sold_before_promo)) / SUM(base_price*quantity_sold_before_promo) * 100 AS 'IR%',
	RANK() OVER( order by (SUM(base_price*quantity_sold_after_promo) - SUM(base_price*quantity_sold_before_promo)) / SUM(base_price*quantity_sold_before_promo) DESC) as rank_order
FROM
    fact_events
        INNER JOIN 
	dim_products ON fact_events.product_code = dim_products.product_code
        INNER JOIN 
	dim_campaigns ON fact_events.campaign_id = dim_campaigns.campaign_id
GROUP BY 
	product_name, campaign_name, category
LIMIT 5;
    
    
    
    
    
    
    
    
    
