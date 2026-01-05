import snowflake.connector
import json
import sys
import os

# --- CONFIGURATION ---
CONTRACT_PATH = "contracts/marketing_v1.json"

SNOWFLAKE_USER = "YOUR_USERNAME" 
SNOWFLAKE_PASSWORD = "YOUR_PASSWORD"
SNOWFLAKE_ACCOUNT = "YOUR_ORG-YOUR_ACCOUNT"
SNOWFLAKE_ROLE = "MARKETING_DEV_ROLE"
SNOWFLAKE_WAREHOUSE = "MARKETING_WH"

def get_snowflake_connection():
    return snowflake.connector.connect(
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        account=SNOWFLAKE_ACCOUNT,
        role=SNOWFLAKE_ROLE,
        warehouse=SNOWFLAKE_WAREHOUSE
    )

def validate_schema(cursor, database, schema, table, contract_columns):
    print(f"🔍 Inspecting {database}.{schema}.{table}...")
    
    try:
        cursor.execute(f"DESC TABLE {database}.{schema}.{table}")
        rows = cursor.fetchall()
        
        # Create a dictionary of actual columns {name: type}
        # Snowflake returns types like "VARCHAR(16777216)", we simplify to base types for this demo
        actual_columns = {row[0]: row[1] for row in rows}
        
        errors = []
        
        for col in contract_columns:
            expected_name = col['name']
            expected_type = col['type']
            
            if expected_name not in actual_columns:
                errors.append(f"❌ Missing Column: {expected_name}")
                continue
                
            # Basic type check (Loose matching for demo purposes)
            actual_type = actual_columns[expected_name]
            if expected_type == "TEXT" and "VARCHAR" not in actual_type:
                errors.append(f"⚠️ Type Mismatch for {expected_name}: Expected TEXT, got {actual_type}")
            elif expected_type == "NUMBER" and "NUMBER" not in actual_type:
                errors.append(f"⚠️ Type Mismatch for {expected_name}: Expected NUMBER, got {actual_type}")

        return errors

    except Exception as e:
        return [f"❌ Table access failed: {str(e)}"]

def main():
    # 1. Load Contract
    try:
        with open(CONTRACT_PATH) as f:
            contract = json.load(f)
    except FileNotFoundError:
        print("❌ Contract file not found.")
        sys.exit(1)

    print(f"📋 Validating Contract: {contract['domain']}/{contract['dataset']} (v{contract['version']})")

    # 2. Connect to Snowflake
    try:
        conn = get_snowflake_connection()
        cur = conn.cursor()
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        sys.exit(1)

    # 3. Validate
    # Mapping our contract context to physical location
    # In a real mesh, this mapping would be in a config file
    db = "MARKETING_DB"
    schema = "ANALYTICS"
    table = "CAMPAIGN_PERFORMANCE"

    errors = validate_schema(cur, db, schema, table, contract['schema'])

    # 4. Report
    if errors:
        print("\n🚫 CONTRACT VIOLATION DETECTED:")
        for e in errors:
            print(e)
        sys.exit(1) # Fail the build
    else:
        print("\n✅ Contract Verified! Pipeline is safe to deploy.")
        sys.exit(0)

if __name__ == "__main__":
    main()
