-- ==========================================================
-- STEP 1: CONTEXT
-- Switch to the Marketing Engineer persona
-- ==========================================================
USE ROLE MARKETING_DEV_ROLE;
USE WAREHOUSE MARKETING_WH;
USE DATABASE MARKETING_DB;

-- Create Schema for Raw Data
CREATE SCHEMA IF NOT EXISTS RAW;

-- ==========================================================
-- STEP 2: FILE FORMAT
-- Tell Snowflake how to read the JSON files
-- ==========================================================
CREATE OR REPLACE FILE FORMAT JSON_FORMAT
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;

-- ==========================================================
-- STEP 3: EXTERNAL STAGE
-- Point Snowflake to the S3 Bucket
-- REPLACE WITH YOUR ACTUAL KEYS AND BUCKET NAME
-- ==========================================================
CREATE OR REPLACE STAGE MARKETING_RAW_STAGE
  URL='s3://datamesh-demo-v1-marketing-raw/' 
  CREDENTIALS=(AWS_KEY_ID='YOUR_ACCESS_KEY' AWS_SECRET_KEY='YOUR_SECRET_KEY')
  FILE_FORMAT = JSON_FORMAT;

-- ==========================================================
-- STEP 4: RAW TABLE
-- A flexible table to hold the raw JSON blob
-- ==========================================================
CREATE OR REPLACE TABLE RAW.CLICKS_JSON (
    raw_data VARIANT,
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ==========================================================
-- STEP 5: LOAD DATA (Manual Copy)
-- In prod, we would use Snowpipe for auto-ingestion
-- ==========================================================
COPY INTO RAW.CLICKS_JSON
FROM @MARKETING_RAW_STAGE;

-- Verify data load
SELECT * FROM RAW.CLICKS_JSON LIMIT 10;