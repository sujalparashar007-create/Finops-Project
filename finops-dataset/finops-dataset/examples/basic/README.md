# finops-dataset — Basic Example

Minimal example that creates a BigQuery dataset with IAM bindings.
## Usage

```hcl
module "finops_dataset" {
  source = "../../"

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

## Run

```bash
cd finops-dataset/examples/basic
terraform init
terraform validate
terraform plan
```

## What it creates

- `google_bigquery_dataset` — Dataset for FinOps reporting views
- `google_bigquery_dataset_iam_binding` — Per-role IAM bindings

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | `"my-project-id"` | GCP project ID for the BigQuery dataset |
| `dataset_iam` | `map(list(string))` | `{"roles/bigquery.dataViewer" = ["group:finops-team@example.com"]}` | Dataset-level IAM bindings |

## Outputs

| Name | Description |
|------|-------------|
| `dataset_id` | BigQuery dataset ID |
| `dataset_full_id` | Fully qualified dataset reference (project.dataset) |
