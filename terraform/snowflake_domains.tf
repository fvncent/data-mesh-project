# ==============================================================================
# DOMAIN 1: MARKETING
# ==============================================================================

# 1. Compute Isolation (FinOps: Track Marketing costs separately)
resource "snowflake_warehouse" "marketing_wh" {
  name           = "MARKETING_WH"
  warehouse_size = "x-small"
  auto_suspend   = 60
  initially_suspended = true
}

# 2. Storage Isolation
resource "snowflake_database" "marketing_db" {
  name = "MARKETING_DB"
}

# 3. RBAC (Security)
resource "snowflake_role" "marketing_dev_role" {
  name    = "MARKETING_DEV_ROLE"
  comment = "Role for Marketing Data Engineers"
}

# 4. Grants: Connect the Role to the Resources
resource "snowflake_grant_privileges_to_account_role" "marketing_wh_usage" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_role.marketing_dev_role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.marketing_wh.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "marketing_db_all" {
  privileges        = ["USAGE", "CREATE SCHEMA", "MODIFY"]
  account_role_name = snowflake_role.marketing_dev_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.marketing_db.name
  }
}

# ==============================================================================
# DOMAIN 2: FINANCE
# ==============================================================================

resource "snowflake_warehouse" "finance_wh" {
  name           = "FINANCE_WH"
  warehouse_size = "x-small" # Start small, scale up via code if needed
  auto_suspend   = 60
  initially_suspended = true
}

resource "snowflake_database" "finance_db" {
  name = "FINANCE_DB"
}

resource "snowflake_role" "finance_dev_role" {
  name    = "FINANCE_DEV_ROLE"
  comment = "Role for Finance Data Engineers"
}

resource "snowflake_grant_privileges_to_account_role" "finance_wh_usage" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_role.finance_dev_role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.finance_wh.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "finance_db_all" {
  privileges        = ["USAGE", "CREATE SCHEMA", "MODIFY"]
  account_role_name = snowflake_role.finance_dev_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.finance_db.name
  }
}