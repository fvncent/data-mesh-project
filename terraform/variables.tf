variable "aws_region" {
  description = "AWS Region for S3 buckets"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_prefix" {
  description = "Prefix to ensure unique bucket names globally"
  type        = string
  default     = "datamesh-demo-v1" 
}

# --- Snowflake Auth ---
# In a real production CI/CD, these would be injected via environment variables
variable "snowflake_account" {
  type = string
}

variable "snowflake_user" {
  type = string
}

variable "snowflake_password" {
  type      = string
  sensitive = true
}