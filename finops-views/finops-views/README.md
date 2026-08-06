# finops-views

Creates BigQuery views that transform raw GCP billing export data into KPI-ready tables.

Views created: `daily_cost`, `monthly_cost_trend`, `cost_by_project`, `top_skus`,
`discounts_and_commitments`, `cost_anomalies`, `finops_budgets`, `monthly_kpi_summary`.

## Usage

```hcl
module "finops_views" {
  source = "../finops-views"

  project_id = "my-project-id"
  dataset_id = "billing_export"

  billing_export_table_id = "my-project.billing_export.gcp_billing_export_resource_v1_XXXXXX"

  budget_targets = module.finops_budgets.budget_amounts
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | (required) | GCP project ID |
| `dataset_id` | `string` | (required) | BigQuery dataset ID |
| `billing_export_table_id` | `string` | `""` | Fully qualified billing export table (empty = skip all views) |
| `budget_targets` | `list(object({...}))` | `[]` | Budget amount structs from finops-budgets |

## Outputs

| Name | Description |
|------|-------------|
| `view_ids` | Map of view name ? fully qualified table ID |
| `project_id` | GCP project ID (passthrough) |
| `dataset_id` | BigQuery dataset ID (passthrough) |
