# finops-dataset

Creates a BigQuery dataset for hosting all FinOps reporting views, plus dataset-level IAM bindings.

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

  iam = {
    "roles/bigquery.dataViewer" = ["group:finops-team@example.com"]
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | (required) | GCP project ID |
| `dataset_id` | `string` | `"billing_export"` | BigQuery dataset ID |
| `location` | `string` | `"EU"` | Dataset location (regional or multi-regional) |
| `labels` | `map(string)` | `{}` | Labels for the dataset |
| `iam` | `map(list(string))` | `{}` | Dataset-level IAM bindings (role ? members) |

## Outputs

| Name | Description |
|------|-------------|
| `dataset_id` | BigQuery dataset ID |
| `project_id` | GCP project ID |
| `dataset_full_id` | Fully qualified dataset reference (project.dataset) |
