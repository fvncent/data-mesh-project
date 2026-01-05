# Enterprise Data Mesh on Snowflake & AWS

![Snowflake](https://img.shields.io/badge/Snowflake-Data_Cloud-blue?style=flat&logo=snowflake)
![AWS](https://img.shields.io/badge/AWS-Infrastructure-orange?style=flat&logo=amazon-aws)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?style=flat&logo=terraform)
![dbt](https://img.shields.io/badge/dbt-Transformation-orange?style=flat&logo=dbt)
![Python](https://img.shields.io/badge/Python-3.9+-yellow?style=flat&logo=python)

A full-scale implementation of a **Data Mesh architecture** featuring decentralized domains (Marketing & Finance), automated data governance, and secure cross-domain data sharing without replication.

## 🏗️ Architecture Overview

This project moves away from the monolithic data warehouse pattern. Instead, it treats data as a product, owned by specific domains, and served securely to consumers via defined contracts.

```mermaid
graph TD
    subgraph "Infrastructure (Terraform)"
        TF[Terraform State] --> |Provisions| S3_M[Marketing S3]
        TF --> |Provisions| S3_F[Finance S3]
        TF --> |Provisions| WH[Snowflake Warehouses & Roles]
    end

    subgraph "Marketing Domain (Producer)"
        GEN_M[Python Generator] --> S3_M
        S3_M --> |Ingest| SF_M[(Marketing DB)]
        SF_M --> |Transform| DBT_M[dbt: Campaign Performance]
        DBT_M --> CONTRACT{Data Contract}
    end

    subgraph "Finance Domain (Consumer)"
        GEN_F[Python Generator] --> S3_F
        S3_F --> |Ingest| SF_F[(Finance DB)]
        SF_F --> |Transform| DBT_F[dbt: ROI Analysis]
        DBT_M -.-> |Secure Share| DBT_F
    end
    
    CONTRACT --> |Pass/Fail| CI_CD[Governance Check]
