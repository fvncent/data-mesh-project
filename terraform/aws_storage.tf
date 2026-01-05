# --- Marketing Domain Landing Zone ---
resource "aws_s3_bucket" "marketing_raw" {
  bucket = "${var.project_prefix}-marketing-raw"
  
  tags = {
    Domain      = "Marketing"
    Environment = "Dev"
    DataMesh    = "Node-1"
  }
}

# --- Finance Domain Landing Zone ---
resource "aws_s3_bucket" "finance_raw" {
  bucket = "${var.project_prefix}-finance-raw"

  tags = {
    Domain      = "Finance"
    Environment = "Dev"
    DataMesh    = "Node-2"
  }
}