# 6-finops \u2014 FinOps Integration & Validation Root Module

Orchestrates all FinOps sub-modules: foundation (IAM + APIs), BigQuery dataset with built-in view factory, billing budgets, Pub/Sub alerts, and a Cloud Function for Teams notifications. Also creates the monthly_kpi_summary view that joins daily cost data with budget targets.

## Prerequisites

1. Stage 0 bootstrap must be complete (seed project, TF service account, GCS state bucket) — run the `bootstrap/` root module, which composes `../projects` (project creation) + `../identities` (tf-executor SA) + bootstrap-specific grants.
2. Manually grant the Terraform SA billing.admin on the billing account before first apply (the `bootstrap/` module grants this automatically for new projects; for existing deployments verify it already exists).
3. Billing export to BigQuery must be enabled on the billing account.

## Usage

Copy terraform.tfvars.example to terraform.tfvars, fill in your values, and run terraform plan / apply.

## Inputs

See variables.tf for all inputs with types, defaults, and validation. Key variables:

- project_id (required) \u2014 GCP project ID for all FinOps resources
- billing_account_id (required) \u2014 GCP billing account ID
- org_id (required) \u2014 Numeric GCP Organization ID
- billing_export_table_id (required) \u2014 Fully qualified billing export table
- region (default: us-east1) \u2014 GCP region
- dataset_location (default: EU) \u2014 BigQuery dataset location
- dataset_id (default: billing_export) \u2014 BigQuery dataset ID
- enable_alert_function (default: true) \u2014 Toggle Teams alerts
- budgets_yaml_path (default: budgets.yaml) \u2014 Budget definitions YAML file
- teams_webhook_url \u2014 Sensitive, set via .tfvars

## Outputs

- dataset_id \u2014 BigQuery dataset ID
- project_id \u2014 GCP project ID
- dataset_full_id \u2014 Fully qualified dataset reference
- view_ids \u2014 Map of view name to fully qualified table ID
- monthly_kpi_summary_id \u2014 Use in Looker Studio / Dashboard 1

## Architecture

Billing Export -> finops_foundation (IAM + APIs)
               -> finops_dataset (dataset + SQL views)
               -> finops_alerts (Pub/Sub + notification channels)
               -> finops_budgets (billing budgets)
               -> finops_function (Cloud Function / Teams notifications)

Budget threshold -> Pub/Sub -> Cloud Function -> Teams

