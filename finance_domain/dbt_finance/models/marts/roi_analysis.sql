{{ config(materialized='table') }}

WITH finance_revenue AS (
    SELECT 
        campaign_id,
        SUM(revenue) as total_revenue
    FROM {{ ref('stg_transactions') }}
    GROUP BY 1
),

marketing_costs AS (
    -- Reading from the Shared Mesh Product
    SELECT 
        campaign_id,
        SUM(total_cost) as total_ad_spend,
        SUM(total_clicks) as total_clicks
    FROM {{ source('marketing_mesh', 'campaign_performance') }}
    GROUP BY 1
)

SELECT
    f.campaign_id,
    m.total_clicks,
    m.total_ad_spend,
    f.total_revenue,
    (f.total_revenue - m.total_ad_spend) as profit,
    CASE 
        WHEN m.total_ad_spend = 0 THEN 0
        ELSE ROUND((f.total_revenue - m.total_ad_spend) / m.total_ad_spend * 100, 2)
    END as roas_percentage
FROM finance_revenue f
JOIN marketing_costs m ON f.campaign_id = m.campaign_id
ORDER BY profit DESC