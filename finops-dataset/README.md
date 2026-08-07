# finops-dataset

Creates a BigQuery dataset for hosting all FinOps reporting views, plus dataset-level IAM bindings and a built-in BigQuery view factory gated by `enable_views`.

## Usage

```hcl
module "finops_dataset" {
  source = "../finops-dataset"

  project_id = "my-project-id"
  dataset_id = "billing_export"
  location   = "EU"

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  iam = [
    { role = "roles/bigquery.dataViewer", member = "group:finops-team@example.com" },
  ]

  enable_views = true
  views = {
    daily_cost = {
      friendly_name = "Daily Net Cost"
      query         = "SELECT ..."
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | (required) | GCP project ID |
| `dataset_id` | `string` | `"billing_export"` | BigQuery dataset ID |
| `existing_dataset_id` | `string` | `null` | Use an existing dataset instead of creating one |
| `location` | `string` | `"EU"` | Dataset location (regional or multi-regional) |
| `labels` | `map(string)` | `{}` | Labels for the dataset |
| `iam` | `list(object({role, member}))` | `[]` | Dataset-level IAM grants (additive) |
| `enable_views` | `bool` | `true` | Create BigQuery views from var.views |
| `views` | `map(object({friendly_name, query}))` | `{}` | View definitions (requires enable_views = true) |

## Outputs

| Name | Description |
|------|-------------|
| `dataset_id` | BigQuery dataset ID |
| `project_id` | GCP project ID |
| `dataset_full_id` | Fully qualified dataset reference (project.dataset) |

