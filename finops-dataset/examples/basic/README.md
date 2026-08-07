# finops-dataset — Basic Example

Minimal example that creates a BigQuery dataset with additive IAM grants.
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

  iam = [
    { role = "roles/bigquery.dataViewer", member = "group:finops-team@example.com" },
  ]
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
- `google_bigquery_dataset_iam_member` — Additive IAM grants per role/member pair

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | `"my-project-id"` | GCP project ID for the BigQuery dataset |
| `iam` | `list(object({role,member}))` | `[{ role = "roles/bigquery.dataViewer", member = "group:finops-team@example.com" }]` | Additive IAM grants |

## Outputs

| Name | Description |
|------|-------------|
| `dataset_id` | BigQuery dataset ID |
| `dataset_full_id` | Fully qualified dataset reference (project.dataset) |
