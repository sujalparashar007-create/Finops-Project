# finops-views — Basic Example

Minimal example that creates BigQuery reporting views including the monthly KPI summary.
## Usage

```hcl
module "finops_views" {
  source = "../../"

  project_id = "my-project-id"
  dataset_id = "billing_export"

  billing_export_table_id = "my-project.billing_export.gcp_billing_export_resource_v1_XXXXXX"

  budget_targets = [{
    month         = "2026-08"
    project_id    = "my-project"
    currency      = "USD"
    budget_amount = 1000
  }]
}
```

## Run

```bash
cd finops-views/examples/basic
terraform init
terraform validate
terraform plan
```

## What it creates

- 8 BigQuery views: `daily_cost`, `monthly_cost_trend`, `cost_by_project`, `top_skus`, `discounts_and_commitments`, `cost_anomalies`, `finops_budgets`, `monthly_kpi_summary`

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | `"my-project-id"` | GCP project ID for the BigQuery views |
| `dataset_id` | `string` | `"billing_export"` | BigQuery dataset ID |
| `billing_export_table_id` | `string` | `"my-project.billing_export.gcp_billing_export_resource_v1_XXXXXX"` | Fully qualified billing export table |
| `budget_targets` | `list(object({...}))` | `[{month = "2026-08", project_id = "my-project", currency = "USD", budget_amount = 1000}]` | Budget amount structs from finops-budgets |

## Outputs

| Name | Description |
|------|-------------|
| `view_ids` | Map of view name to fully qualified table ID |
| `monthly_kpi_summary_id` | Fully qualified monthly_kpi_summary view ID for Looker Studio |
