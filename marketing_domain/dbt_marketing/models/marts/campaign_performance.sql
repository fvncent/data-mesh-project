-- models/marts/campaign_performance.sql
-- THIS IS THE "DATA PRODUCT" EXPOSED TO THE MESH
{{ config(materialized='table') }}

WITH clicks AS (
    SELECT * FROM {{ ref('stg_clicks') }}
)

SELECT 
    campaign_id,
    DATE_TRUNC('hour', click_timestamp) as report_hour,
    COUNT(click_id) as total_clicks,
    SUM(cost) as total_cost,
    AVG(cost) as avg_cpc
FROM clicks
GROUP BY 1, 2