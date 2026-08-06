# test-finops-dataset — FinOps Integration & Validation Root Module

Orchestrates all FinOps sub-modules (BigQuery dataset, SQL views, billing budgets, Pub/Sub alerts, budget controls) and deploys a Cloud Function for email/Teams notifications. Also creates the monthly_kpi_summary view that joins daily cost data with budget targets.

## Prerequisites

1. Stage 0 bootstrap must be complete (seed project, TF service account, GCS state bucket).
2. Manually grant the Terraform SA billing.admin on the billing account before first apply.
3. Billing export to BigQuery must be enabled on the billing account.

## Usage

Copy terraform.tfvars.example to terraform.tfvars, fill in your values, and run terraform plan / apply.

## Inputs

See variables.tf for all inputs with types, defaults, and validation. Key variables:

- project_id (required) — GCP project ID for all FinOps resources
- billing_account_id (required) — GCP billing account ID
- billing_export_table_id (required) — Fully qualified billing export table
- region (default: us-east1) — GCP region
- enable_alert_function (default: true) — Toggle email/Teams alerts
- gmail_user / gmail_app_password / teams_webhook_url — Sensitive, set via .tfvars

## Outputs

- dataset_id — BigQuery dataset ID
- project_id — GCP project ID
- dataset_full_id — Fully qualified dataset reference
- view_ids — Map of view name to fully qualified table ID
- monthly_kpi_summary_id — Use in Looker Studio / Dashboard 1

## Architecture

Billing Export -> finops_dataset -> finops_views (6 SQL views)
                              -> finops_budgets (budgets + budget view)
                              -> finops_alerts (Pub/Sub + email channels)
                              -> finops_budget_controls (scoped budgets)
                              -> monthly_kpi_summary (KPI view)

Budget threshold -> Pub/Sub -> Cloud Function -> Gmail + Teams