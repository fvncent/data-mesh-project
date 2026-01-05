-- models/staging/stg_clicks.sql
-- This model flattens the JSON and cleans the data
WITH source AS (
    SELECT * FROM {{ source('marketing', 'clicks_json') }}
),

flattened AS (
    SELECT 
        raw_data:event_id::STRING as click_id,
        raw_data:event_timestamp::TIMESTAMP as click_timestamp,
        raw_data:campaign_id::STRING as campaign_id,
        raw_data:user_id::STRING as user_id,
        raw_data:cost_per_click::FLOAT as cost,
        raw_data:is_bot_traffic::BOOLEAN as is_bot
    FROM source
)

SELECT * FROM flattened
-- Filter out bot traffic immediately (Governance/Quality)
WHERE is_bot = FALSE