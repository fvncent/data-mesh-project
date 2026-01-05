-- ==========================================================
-- STEP 1: FINANCE INGESTION SETUP
-- ==========================================================
USE ROLE FINANCE_DEV_ROLE;
USE WAREHOUSE FINANCE_WH;
USE DATABASE FINANCE_DB;

CREATE SCHEMA IF NOT EXISTS RAW;

CREATE OR REPLACE FILE FORMAT JSON_FORMAT
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;

-- REPLACE WITH YOUR KEYS & BUCKET
CREATE OR REPLACE STAGE FINANCE_RAW_STAGE
  URL='s3://datamesh-demo-v1-finance-raw/' 
    CREDENTIALS=(AWS_KEY_ID='YOUR_ACCESS_KEY' AWS_SECRET_KEY='YOUR_SECRET_KEY')
  FILE_FORMAT = JSON_FORMAT;

CREATE OR REPLACE TABLE RAW.TRANSACTIONS_JSON (
    raw_data VARIANT,
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Load Data
COPY INTO RAW.TRANSACTIONS_JSON (raw_data)
FROM (SELECT $1 FROM @FINANCE_RAW_STAGE);

-- ==========================================================
-- STEP 2: THE MESH HANDSHAKE (Access Grant)
-- The Marketing Team explicitly grants access to Finance.
-- In a real mesh, this is automated via a Governance Platform.
-- ==========================================================
USE ROLE MARKETING_DEV_ROLE;

-- 1. Allow Usage of the Database & Schema
GRANT USAGE ON DATABASE MARKETING_DB TO ROLE FINANCE_DEV_ROLE;
GRANT USAGE ON SCHEMA MARKETING_DB.ANALYTICS TO ROLE FINANCE_DEV_ROLE;

-- 2. Allow Select on the specific Data Product
GRANT SELECT ON TABLE MARKETING_DB.ANALYTICS.CAMPAIGN_PERFORMANCE TO ROLE FINANCE_DEV_ROLE;

-- ==========================================================
-- STEP 3: VERIFY ACCESS
-- Switch back to Finance and try to read Marketing data
-- ==========================================================
USE ROLE FINANCE_DEV_ROLE;
SELECT * FROM MARKETING_DB.ANALYTICS.CAMPAIGN_PERFORMANCE LIMIT 10;