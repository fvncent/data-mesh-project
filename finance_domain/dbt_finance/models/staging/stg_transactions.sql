WITH source AS (
    SELECT * FROM {{ source('finance', 'transactions_json') }}
)

SELECT 
    raw_data:transaction_id::STRING as transaction_id,
    raw_data:transaction_at::TIMESTAMP as transaction_at,
    raw_data:campaign_id::STRING as campaign_id,
    raw_data:amount::FLOAT as revenue
FROM source